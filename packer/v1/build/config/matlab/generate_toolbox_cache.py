# Copyright 2023 The MathWorks Inc.
"""! @brief Python program to generate the toolbox-cache xml for MATLAB

 generate_toolbox_cache.py file takes matlabroot and toolbox-cache xml destination folder as inputs,
 It recursively goes over all folders mentioned in <matlabroot>/toolbox/local/path/*.phl files.
 and creates a toolbox-cache xml in specified destination folder.
 Note: Generated toolbox-cache xml will not have class definition for files.
 Unknown 'U' will be assigned to all files as class definition.
 We can place the generated toolbox-cache xml in <matlabroot>/toolbox/local.
"""
import argparse
import platform
import typing
from pathlib import Path
from datetime import datetime
from xml.etree import ElementTree as ET


VALID_CHILD_HASH = {
    "folder": {"package", "method", "udd", "private", "resources"},
    "package": {"package", "method", "udd", "private", "resources"},
    "method": {"udd", "private", "resources"},
    "udd": {"private"},
}

PLATFORM_LABEL_HASH = {"Windows": "win64", "Linux": "glnxa64"}


def get_folder_type(folder_name: str, parent_folder_type: str) -> str:
    """Folder type conventions"""
    # package: folder name starts with '+'
    # method: folder name starts with '@'
    # udd: folder name starts with '@'
    #      and its parent folder is of type 'method'
    # private: folder name is 'private'
    # resources: folder name is 'resources'

    if folder_name.startswith("+"):
        return "package"
    if folder_name.startswith("@"):
        if parent_folder_type == "method":
            return "udd"
        return "method"
    if folder_name == "private":
        return "private"
    if folder_name == "resources":
        return "resources"
    return ""


def generate_toolbox_cache(
    file_path: Path, depth: int, parent_folder_type: str, matlabroot_path: Path
) -> str:
    """
    generate_toolbox_cache recursively goes over a root folder (file_path)
    and it forms xml tree structure of folders and files under root folder.
    """
    if not file_path.is_dir():
        return ""
    temp_tree = ""
    spaces = " " * depth
    root_folder = file_path.relative_to(matlabroot_path).as_posix()
    for child_file_path in file_path.glob("*"):
        file_name = child_file_path.name
        if child_file_path.is_dir():
            if ("private" != parent_folder_type) and (
                (file_name.startswith("+"))
                or (file_name.startswith("@"))
                or (file_name in ["private", "resources"])
            ):
                child_folder_type = get_folder_type(file_name, parent_folder_type)
                if child_folder_type not in VALID_CHILD_HASH[parent_folder_type]:
                    continue
                sub_tree = generate_toolbox_cache(
                    child_file_path, depth + 1, child_folder_type, matlabroot_path
                )
                if sub_tree:
                    temp_tree = f"{temp_tree}{sub_tree}\n"
        else:
            temp_tree = f'{temp_tree} {spaces}<U name="{file_name}"/>\n'
    temp_tree = f'{spaces}<D name="{root_folder}">\n{temp_tree}{spaces}</D>'
    return temp_tree


def get_phl_root_folders(matlabroot_path: Path) -> typing.List:
    """
    Returns list of folders which contain *.phl files for parsing.
    List has matlabroot and (supportpackageroot*) paths.
    supportpackageroot path is only added to list when its path is relative to matlabroot path.
    """
    supportpackage_setting_xml = "toolbox/local/supportpackagerootsetting.xml"
    phl_root_folders_list = [matlabroot_path]
    # add support package root path if it exists and is valid
    try:
        if Path.joinpath(matlabroot_path, supportpackage_setting_xml).exists():
            supportpackage_path = get_supportpackage_path(
                Path(f"{matlabroot_path}/{supportpackage_setting_xml}")
            )
            if supportpackage_path.relative_to(matlabroot_path):
                phl_root_folders_list.append(supportpackage_path)
            else:
                print(
                    "supportpackageroot path and matlabroot path are not relative to each other,"
                    f'so not adding supportpackage path to toolbox-cache xml\n \
                    supportpackage_path: "{supportpackage_path}"\nmatlabroot_path: "{matlabroot_path}"'
                )
    except Exception as exception:
        print(exception)
        print(
            "Unable to add supportpackageroot path so generating toolbox-cache xml for matlabroot"
        )
    return phl_root_folders_list


def get_supportpackage_path(supportpackage_xml_path: Path) -> Path:
    """
    Returns supportpackage installation path from supportpackage_xml
    """
    root = ET.parse(supportpackage_xml_path)
    for setting in root.findall(".//Setting"):
        setting_value = setting.text
        if setting_value:
            return Path(setting_value)
    raise Exception("Setting tag is empty or tag is missing in supportpackage xml")


def validate_toolbox_cache_xml(toolbox_cache_xml_path: Path):
    """
    Validates if XML file is not malformed and root node is 'Mathworks'
    """
    toolbox_cache_xml_tree = ET.parse(toolbox_cache_xml_path).getroot()
    if toolbox_cache_xml_tree.tag == "MathWorks":
        print("Generated toolbox-cache xml is valid")
    else:
        raise Exception("Generated xml does not have MathWorks root node")


def create_arg_parser() -> argparse.ArgumentParser:
    """
    Inputs to Parse are matlabroot and toolbox-cache xml destination folder
    """
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument("matlabroot", help="<matlabroot> folder path", type=str)
    arg_parser.add_argument(
        "toolbox_destination_folder", help="toolbox destination folder path", type=str
    )
    return arg_parser


def add_file_to_cache(
    file_path: Path,
    toolbox_cache_str: str,
    phl_root_folder_path: Path,
    matlabroot_path: Path,
) -> str:
    """
    add_file_to_cache parses over each folder present in input file and generates toolbox cache
    """
    with open(file_path, "r", encoding="ASCII") as file:
        for line in file:
            if not line.startswith("%"):
                folder_path = Path(phl_root_folder_path, line.strip())
                if folder_path.is_dir():
                    toolbox_sub_tree = generate_toolbox_cache(
                        folder_path, 1, "folder", matlabroot_path
                    )
                    toolbox_cache_str = f"{toolbox_cache_str}\n{toolbox_sub_tree}"
    return toolbox_cache_str


if __name__ == "__main__":
    parser = create_arg_parser()
    args = parser.parse_args()
    matlabroot = Path(args.matlabroot)
    toolbox_destination = Path(args.toolbox_destination_folder)
    toolbox_cache = ""
    print("Generating toolbox-cache now")
    date = datetime.now().strftime("%a %b %d %H:%M:%S %Y")
    platform_system = platform.system()
    if platform_system in PLATFORM_LABEL_HASH:
        platform_label = PLATFORM_LABEL_HASH[platform_system]
    else:
        raise Exception(f"Unsupported platform {platform_system}")
    phl_root_folders = get_phl_root_folders(matlabroot)
    for phl_root_folder in phl_root_folders:
        for phl_file in Path.joinpath(phl_root_folder, "toolbox/local/path").glob(
            "*.phl"
        ):
            toolbox_cache = add_file_to_cache(
                phl_file, toolbox_cache, phl_root_folder, matlabroot
            )

    toolbox_cache = (
        f'<MathWorks type="Path Cache File" version="2.0" date="{date}">'
        f"{toolbox_cache}\n</MathWorks>"
    )
    with open(
        toolbox_destination / f"toolbox_cache-{platform_label}.xml",
        "w",
        encoding="utf-8",
    ) as f:
        f.write(toolbox_cache)
    validate_toolbox_cache_xml(
        toolbox_destination / f"toolbox_cache-{platform_label}.xml"
    )
