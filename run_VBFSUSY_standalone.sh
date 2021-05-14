#!/bin/bash
#set -e # exit when any command fails

# defaults
ecms=13
mass=150
dM=1
proc=VBFSUSY_EWKQCD
cores=20
nevents=10000
params=Higgsino
mmjj=500
mmjjmax=-1
deltaeta=3.0
ptj=20
suffix=""
skip_mgpy=false
skip_delphes=false
skip_ana=false
skip_SA=true
clobber_mgpy=false
clobber_delphes=false
clobber_ana=false
base=${PWD}
database=/data/users/${USER}/SUSY
datadir=${tag}
ktdurham=-1
seed=0
pythia_card="cards/pythia/pythia8_card_dipoleRecoil.dat"
anascript="SimpleAna.py"

# some modifications based on run parameters
lumi=1
if [[ $ecms == 13 ]]; then
    if [ "$mass" -ge "1000" ]; then
	exit
    fi
    lumi=140000
    delphescard="delphes_card_ATLAS.tcl"
elif [[ $ecms == 14 ]]; then
    if [ "$mass" -ge "1000" ]; then
	exit
    fi
    lumi=3000000
    delphescard="delphes_card_ATLAS.tcl"
elif [[ $ecms == 100 ]]; then
    if [ "$mass" -le "200" ]; then
	exit
    fi
    lumi=3000000
    delphescard="FCChh.tcl"
fi


# get command line options
while getopts "E:M:P:p:N:m:x:s:e:c:GDAglaB:b:j:S:y:k:d:C:iL:" opt; do
    case "${opt}" in
	E) ecms=$OPTARG;;
	M) mass=$OPTARG;;
	P) proc=$OPTARG;;
	p) params=$OPTARG;;
	N) nevents=$OPTARG;;
	m) mmjj=$OPTARG;;
	x) mmjjmax=$OPTARG;;
	s) suffix=$OPTARG;;
	e) deltaeta=$OPTARG;;
	c) cores=$OPTARG;;
	G) skip_mgpy=true;;
	D) skip_delphes=true;;
	A) skip_ana=true;;
	g) clobber_mgpy=true;;
	l) clobber_delphes=true;;
	a) clobber_ana=true;;
	B) base=$OPTARG;;
	b) database=$OPTARG;;
	j) ptj=$OPTARG;;
	S) dM=$OPTARG;;
	y) pythia_card=$OPTARG;;
	k) ktdurham=$OPTARG;;
	d) seed=$OPTARG;;
	C) anascript=$OPTARG;;
	i) skip_SA=false;;
	L) delphescard=$OPTARG;;
	\?) echo "Invalid option: -$OPTARG";;
    esac
done

echo $anascript
echo $clobber_ana

# construct the tag.
tag="VBFSUSY_${ecms}_${params}_${mass}_mmjj_${mmjj}_${mmjjmax}${suffix}"

# run MadGraph+Pythia, using test script
if $skip_mgpy; then
    echo "Skipping Madgraph for this job."
else
    clobberopt=""
    if $clobber_mgpy; then
	clobberopt="-g"
    fi

    ./test/wrapper_mgpy.sh \
	-b ${database} \
	-P ${proc} \
	-p ${params} \
	-y "cards/pythia/pythia8_card_dipoleRecoil.dat" \
	-S ${dM} \
	-M ${mass} \
	-m ${mmjj} \
	-x ${mmjjmax} \
	-e ${deltaeta} \
	-E ${ecms} \
	-c ${cores} \
	-k ${ktdurham} \
	-N ${nevents} \
	-d ${seed} \
	-j ${ptj} \
	${clobberopt} \
	${tag}
fi

# run Delphes, using test script
if $skip_delphes; then
    echo "Skipping delphes for this job."
else
    ./test/wrapper_delphes.sh ${tag} ${delphescard}  ${cores} ${clobber_delphes}
fi


# run ntuplizing, using test script
if $skip_ana; then
    echo "Skipping ana for this job."
else
    XS=$(grep "Cross-section :" ${database}/${tag}/docker_mgpy.log | tail -1 | awk '{print $8}')
    set -x
    ./test/wrapper_ana.sh ${tag} ${lumi} ${clobber_ana} ${database} ${anascript} ${XS}
    set +x
fi


# run SimpleAnalysis.  not usual.
if $skip_SA; then
    echo "Skipping SimpleAnalysis for this job."
else
    # probably going to need some way to rescale these outputs.
    ./test/wrapper_SimpleAnalysis.sh ${tag} ${lumi} ${database}
fi
