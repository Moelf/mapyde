# mario-mapyde v0.4.1

MaPyDe stands for MadGraph-Pythia-Delphes which is a utility that allows one to
run all of the various HEP toolings or chain them together and perform a quick
analysis with the results, such as running CERN ATLAS SimpleAnalysis or pyhf.

---

<!-- sync the following div with docs/index.md -->
<div align="center">

<img src="https://raw.githubusercontent.com/scipp-atlas/mario-mapyde/main/docs/assets/images/logo.svg" alt="Mapyde logo" width="500" role="img">

<!-- --8<-- [start:badges] -->

<!-- prettier-ignore-start -->
| | |
| --- | --- |
| CI/CD | [![CI - Test][actions-badge-ci]{ loading=lazy .off-glb }][actions-link-ci] [![CI - Docker][actions-badge-docker]{ loading=lazy .off-glb }][actions-link-docker] |
| Docs | [![Docs][actions-badge-docs]{ loading=lazy .off-glb }][actions-link-docs] |
| Package | [![PyPI - Downloads][pypi-downloads]{ loading=lazy .off-glb }][pypi-link] [![PyPI - Version][pypi-version]{ loading=lazy .off-glb }][pypi-link] [![PyPI platforms][pypi-platforms]{ loading=lazy .off-glb }][pypi-link] [![Conda-Forge][conda-badge]{ loading=lazy .off-glb }][conda-link] |
| Meta | [![GitHub - Discussion][github-discussions-badge]{ loading=lazy .off-glb }][github-discussions-link] [![GitHub - Issue][github-issues-badge]{ loading=lazy .off-glb }][github-issues-link] [![License - Apache 2.0][license-badge]{ loading=lazy .off-glb }][license-link] |

[actions-badge-ci]:         https://github.com/scipp-atlas/mario-mapyde/actions/workflows/ci.yml/badge.svg?branch=main
[actions-link-ci]:          https://github.com/scipp-atlas/mario-mapyde/actions/workflows/ci.yml
[actions-badge-docker]:     https://github.com/scipp-atlas/mario-mapyde/actions/workflows/docker.yml/badge.svg?branch=main
[actions-link-docker]:      https://github.com/scipp-atlas/mario-mapyde/actions/workflows/docker.yml
[actions-badge-docs]:       https://github.com/scipp-atlas/mario-mapyde/actions/workflows/docs.yml/badge.svg?branch=main
[actions-link-docs]:        https://github.com/scipp-atlas/mario-mapyde/actions/workflows/docs.yml
[conda-badge]:              https://img.shields.io/conda/vn/conda-forge/mapyde
[conda-link]:               https://github.com/conda-forge/mapyde-feedstock
[github-discussions-badge]: https://img.shields.io/static/v1?label=Discussions&message=Ask&color=blue&logo=github
[github-discussions-link]:  https://github.com/scipp-atlas/mario-mapyde/discussions
[github-issues-badge]:      https://img.shields.io/static/v1?label=Issues&message=File&color=blue&logo=github
[github-issues-link]:       https://github.com/scipp-atlas/mario-mapyde/issues
[pypi-link]:                https://pypi.org/project/mapyde/
[pypi-downloads]:           https://img.shields.io/pypi/dm/mapyde.svg?color=blue&label=Downloads&logo=pypi&logoColor=gold
[pypi-platforms]:           https://img.shields.io/pypi/pyversions/mapyde
[pypi-version]:             https://badge.fury.io/py/mapyde.svg
[license-badge]:            https://img.shields.io/badge/License-Apache_2.0-blue.svg
[license-link]:              https://spdx.org/licenses/Apache-2.0.html
<!-- prettier-ignore-end -->

<!-- --8<-- [end:badges] -->

</div>

## Docker Images

Docker images are made available in our
[container registry](../../../container_registry).

```
docker pull ghcr.io/scipp-atlas/mario-mapyde/madgraph
docker pull ghcr.io/scipp-atlas/mario-mapyde/delphes
docker pull ghcr.io/scipp-atlas/mario-mapyde/pyplotting
```

If you want to run on a machine with an NVidia GPU and use it for limit setting
with `pyhf`, then there's a container for that too:

```
docker pull ghcr.io/scipp-atlas/mario-mapyde/pyplotting-cuda
```

## Running

Everyone is centralized around the concept of providing a user configuration
file that references a template. By default,
[defaults.toml](./templates/defaults.toml) is used (if not specified). These
configuration files significantly control how to run or execute the various
steps in the chain of `mapyde`. Use the command line interface to get started:

```
# display the help
mapyde --help

# display the prefix path for data cards shipped with mapyde
mapyde --prefix cards

# parse and display the config
mapyde config parse user.toml

# run all steps
maypde run all user.toml

# run only madgraph
mapyde run madgraph user.toml

# display the help for running
mapyde run --help
```

## Configuration Details

There are a lot of different configuration options one can specify. For right
now, the user is asked to look at [defaults.toml](./templates/defaults.toml),
run `mapyde config parse user.toml`, open a
[discussion][github-discussions-link], or look at the source code.

### MadGraph

Produces a `hepmc` file. You can:

- specify process, param, and run cards
  - define particle masses in config file
  - define additional kinematic cuts to apply at parton level
- specify pythia card
- define center of mass energy

### Delphes

Run a parameterized detector simulation, outputting a `ROOT` file. You can:

- specify Delphes card

### Analysis

Analyze the Delphes output, which could be user-provided analysis code. There
are some scripts already provided for you:

- [scripts/Delphes2SA.py](./scripts/Delphes2SA.py) will make an ntuple that can
  be parsed by `SimpleAnalysis` for limit setting.
- [scripts/SimpleAna.py](./scripts/SimpleAna.py) will make a generic "flat"
  ntuple in a ROOT file.
- [scripts/muscan.py](./scripts/muscan.py) will use pyhf to perform a mu-scan
  and compute upper-limits for a public likelihood injected with results from
  `SimpleAnalysis`.
