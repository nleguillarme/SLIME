import os
import pandas as pd
import re


def split_blocks(lines):
    whitelines_indices = [
        i for i, line in enumerate(lines) if re.match("^[^a-zA-Z0-9]*$", line)
    ]
    block_start_indices = [
        whitelines_indices[i] + 1
        for i in range(len(whitelines_indices) - 1)
        if whitelines_indices[i] + 1 != whitelines_indices[i + 1]
    ]
    block_start_indices = [
        i for i in block_start_indices if not lines[i].startswith("#")
    ]
    return block_start_indices


def clean(f_in, **kwargs):
    def is_subtract_group_line(line):
        return line.startswith("subtract_group:")

    def is_add_group_line(line):
        return line.startswith("add_group:")

    def parse_group_definition(line):
        parsed = {}
        group, group_definition = tuple([i for i in line.split("\t") if i])
        parsed["functionalGroup"] = group.strip()
        items = group_definition.split("; ")
        for item in items:
            key, value = tuple(item.split(":"))
            parsed[key] = str(value)
        return group.strip(), parsed

    def parse_member_taxon(line):
        items = line.split("\t")
        member_taxon = items[0].lstrip("*").rstrip("*").split("*")
        taxon_name = []
        for i in reversed(member_taxon):
            taxon_name.append(i)
            if not i.isupper() and i[0].isupper():
                break
        taxon_name = [t.strip() for t in taxon_name if t.strip()]
        scientific_name = " ".join(reversed(taxon_name))
        reference = items[-1].lstrip("# ") if len(items) > 1 else None
        return {"scientificName": scientific_name, "reference": reference}

    text = open(f_in, "r").read()
    lines = text.split("\n")
    lines = [l for l in lines if not l.startswith("# - - - - - - -")]

    functional_table = []
    group_members = {}
    groups = {}
    add_groups = {}
    subtract_groups = {}

    block_start_indices = split_blocks(lines)
    for i in range(len(block_start_indices)):
        block_end_index = (
            block_start_indices[i + 1]
            if i + 1 < len(block_start_indices)
            else len(lines)
        )
        block = lines[block_start_indices[i] : block_end_index]
        block = [l for l in block if (l and not l.startswith("#"))]

        # Parse functional group definition
        group, group_definition = parse_group_definition(block[0])
        add_groups[group] = []
        subtract_groups[group] = []

        members = []
        for line in block[1:]:
            if is_add_group_line(line):
                addgroup = line.split("\t")[0].split(":")[-1].strip()
                add_groups[group].append(addgroup)
            elif is_subtract_group_line(line):
                subtractgroup = line.split("\t")[0].split(":")[-1].strip()
                subtract_groups[group].append(subtractgroup)
            else:
                member_information = parse_member_taxon(line)
                members.append(member_information)

        group_members[group] = members
        groups[group] = group_definition

    for group in groups:
        for addgroup in add_groups[group]:
            group_members[group] += group_members[addgroup]
        for subtractgroup in subtract_groups[group]:
            for member in group_members[subtractgroup]:
                if member in group_members[group]:
                    print("Remove", member, "member of", subtractgroup, "from", group)
                    group_members[group].remove(member)

    for group in groups:
        for member in group_members[group]:
            functional_table.append(dict(groups[group], **member))

    df = pd.DataFrame(functional_table)
    return df


import argparse
from pathlib import Path

parser = argparse.ArgumentParser()

parser.add_argument("--integraph_filepath")
parser.add_argument("--integraph_outputdir")

args = parser.parse_args()

filepath = Path(args.integraph_filepath)
outputdir = Path(args.integraph_outputdir)
output_filepath = outputdir / filepath.name
output_filepath.parent.mkdir(parents=True, exist_ok=True)

df = clean(filepath)

df.to_csv(output_filepath, sep=",")

print(output_filepath)
