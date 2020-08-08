
Tools run inside the docker image provided by Dockerfile, but you can pull it from DockerHub:

```
docker pull mhance:madgraph/pythiainterface
```

For an example of how to run jobs, see ```wrapper_test.sh```:

```
tag="test"

python mg5creator.py \
       -P ProcCards/VBFSUSY_short \
       -r RunCards/default_LO.dat \
       -p ParamCards/Higgsino.slha \
       -y PythiaCards/pythia8_card.dat \
       -m MN1 150.0 -m MN2 155.0 -m MC1 155.0 \
       -E 100000 \
       -n 1000 \
       -t ${tag}


docker run \
       --rm \
       -v $PWD:$PWD -w $PWD \
       mhance/madgraph:pythiainterface \
       "cd output/${tag} && mg5_aMC run.mg5"
```
