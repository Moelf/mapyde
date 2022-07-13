"""
Utilities for managing configuration.
"""

from __future__ import annotations

import os
import sys
import typing as T
from pathlib import Path

import toml
from jinja2 import Environment, FileSystemLoader, Template, filters

from mapyde import cards, data, scripts, templates

# importlib.resources.as_file wasn't added until Python 3.9
# c.f. https://docs.python.org/3.9/library/importlib.html#importlib.resources.as_file
if sys.version_info >= (3, 9):
    from importlib import resources
else:
    import importlib_resources as resources


def merge(
    left: dict[str, T.Any], right: dict[str, T.Any], path: T.Optional[list[str]] = None
) -> dict[str, T.Any]:
    """
    merges right dictionary into left dictionary
    """
    if path is None:
        path = []
    for key in right:
        if key in left:
            if isinstance(left[key], dict) and isinstance(right[key], dict):
                merge(left[key], right[key], path + [str(key)])
            else:
                left[key] = right[key]
        else:
            left[key] = right[key]
    return left


def path_join(path: str, prefix: str) -> str:
    """
    Helper function for jinja2 to join a path.

      {{ "path/to/file.dat" | path_join('/my/prefix') }}

    """

    return str(Path(prefix).joinpath(path))


def paths_join(paths: list[str], prefix: str) -> str:
    """
    Helper function for jinja2 to join paths.

      {{ ["base/path", "file.dat"] | paths_join('/my/prefix') }}

    """

    return str(Path(prefix).joinpath(*paths))


def env_override(value: T.Any, key: str) -> T.Any:
    """
    Helper function for jinja2 to override environment variables
    """
    return os.getenv(key, value)


filters.FILTERS["env_override"] = env_override
filters.FILTERS["path_join"] = path_join
filters.FILTERS["paths_join"] = paths_join


def load_config(filename: str, cwd: str = ".") -> T.Any:
    """
    Helper function to load a local toml configuration by filename
    """
    env = Environment(loader=FileSystemLoader(cwd))

    tpl = env.get_template(filename)
    assert tpl.filename
    return toml.load(open(tpl.filename, encoding="utf-8"))


def build_config(user: dict[str, T.Any]) -> T.Any:
    """
    Function to build a configuration from a user-provided toml configuration on top of the base/template one.
    """
    with resources.as_file(templates.joinpath("defaults.toml")) as template:
        defaults = load_config(template.name, str(template.parent))

    variables = merge(defaults, user)
    tpl = Template(toml.dumps(variables))
    config = toml.loads(
        tpl.render(
            PWD=os.getenv("PWD"),
            USER=os.getenv("USER"),
            MAPYDE_DATA=data,
            MAPYDE_CARDS=cards,
            MAPYDE_SCRIPTS=scripts,
            MAPYDE_TEMPLATES=templates,
            **variables,
        )
    )

    return config
