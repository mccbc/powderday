#!/bin/bash 

#This script sets up a qsub file to submit (serially) a number of
# snapshots in a row using the Torque queue scheduler on Pleiades.  In
# principle it is meant to be called by input_setup_ple.py

#Author: Desika Narayanan

#Notes of interest:

#1. This does *not* set up the parameters_master.py file: it is
#assumed that you will *very carefully* set this up yourself.

#2. This requires bash versions >= 3.0.  To check, type at the shell
#prompt: 

#> $echo $BASH_VERSION

n_nodes=$1
startsnap=$2
endsnap=$3
model_dir=$4
hydro_dir=$5
model_run_name=$6
COSMOFLAG=$7
model_dir_remote=$8
hydro_dir_remote=$9

#n_nodes=6
#startsnap=1
#endsnap=23 #set the same as startsnap if you just want to do one snapshot
#model_dir='/data/desika/db/pd_runs/sbw_mergers/mw_e_hr_DIND'
#hydro_dir='/data/desika/gadgetruns/sbw_mergers/mw_e_hr_DIND'
#model_run_name='mw_e_hr'
#COSMOFLAG=0 #flag




 
for (( i=$startsnap; i<=$endsnap; i++ ))


do

    echo "processing model file for snapshot:  $i"


    #clear the pyc files
    rm -f *.pyc

    #set up the model_**.py file

    filem="$model_dir/model_$i.py"
    rm -f $filem
    
    echo "#Snapshot Parameters" >> $filem
    echo "#<Parameter File Auto-Generated by setup_all_cluster.sh>" >> $filem
    echo "Gadget_snap_num =  $i" >> $filem
    echo -e "\n" >> $filem
    
    echo "if Gadget_snap_num < 10:" >> $filem
    echo -e "\t snapnum_str = '00'+str(Gadget_snap_num)" >> $filem
    echo -e "elif Gadget_snap_num >= 10 and Gadget_snap_num <100:" >> $filem
    echo -e "\t snapnum_str = '0'+str(Gadget_snap_num)" >> $filem
    echo -e "else:" >> $filem
    echo -e "\t snapnum_str = str(Gadget_snap_num)" >> $filem
 
    echo -e "\n" >>$filem
    
    if [ $COSMOFLAG -eq 1 ]
    then
	echo "hydro_dir = '$hydro_dir_remote/snapdir_'+snapnum_str+'/'">>$filem
	echo "snapshot_name = 'snapshot_'+snapnum_str+'.0.hdf5'" >>$filem
    else
	echo "hydro_dir = '$hydro_dir_remote/'">>$filem
	echo "snapshot_name = 'snapshot_'+snapnum_str+'.hdf5'" >>$filem
    fi


    echo -e "\n" >>$filem

    echo "#where the files should go" >>$filem
    echo "PD_output_dir = '${model_dir_remote}/' ">>$filem
    echo "Auto_TF_file = 'snap'+snapnum_str+'.logical' ">>$filem
    echo "Auto_dustdens_file = 'snap'+snapnum_str+'.dustdens' ">>$filem

    echo -e "\n\n" >>$filem
    echo "#===============================================" >>$filem
    echo "#FILE I/O" >>$filem
    echo "#===============================================" >>$filem
    echo "inputfile = PD_output_dir+'/example.'+snapnum_str+'.rtin'" >>$filem
    echo "outputfile = PD_output_dir+'/example.'+snapnum_str+'.rtout'" >>$filem

    echo -e "\n\n" >>$filem
    echo "#===============================================" >>$filem
    echo "#GRID POSITIONS" >>$filem
    echo "#===============================================" >>$filem
    echo "x_cent = 0" >>$filem
    echo "y_cent = 0" >>$filem
    echo "z_cent = 0" >>$filem

done



echo "writing qsub file"
qsubfile="$model_dir/qsub_master.qsub"
rm -f $qsubfile
echo $qsubfile

echo "#PBS -S /bin/bash" >>$qsubfile
echo "#PBS -N $model_run_name" >>$qsubfile
echo "#PBS -l nodes=$n_nodes" >>$qsubfile
echo "#PBS -m abe" >>$qsubfile
echo "#PBS -j oe" >>$qsubfile
echo "#PBS -W group_list=s1550">>$qsubfile
echo "#PBS -M dnarayan@haverford.edu" >>$qsubfile
echo "#PBS -q devel"

echo -e "\n" >>$qsubfile

echo "module purge">>$qsubfile
echo "module load hdf5/1.8.3/intel/mpt" >>$qsubfile
echo "module load comp-intel/2015.0.090" >>$qsubfile
echo "module load mpi-sgi/mpt.2.12r16" >>$qsubfile
echo "module load gsl/1.14" >>$qsubfile
echo "module load szip/2.1/intel" >>$qsubfile
echo "module load git/2.4.5" >>$qsubfile


echo -e "\n" >>$qsubfile
echo "cd /u/dnarayan/pd" >>$qsubfile



 
for (( i=$startsnap; i<=$endsnap; i++ ))
do
    echo $i
    echo "python pd_front_end.py $model_dir_remote parameters_master model_$i  > $model_dir_remote/snap$i.txt">>$qsubfile

done
