#!/bin/bash 

#This script is a modified version of one originally written by Chris
# Hayward back in the good old days.  The basic idea is to set up the
# model and qsub files for a gang of sequential snapshots.
# It's written for gadget-centric numbering to run on a Torque queue
# scheduler (for the convenience of desika) but can be edited easily
# enough.

#Notes of interest:

#1. This does *not* set up the parameters_master.py file: it is
#assumed that you will *very carefully* set this up yourself.

#2. This requires bash versions >= 3.0.  To check, type at the shell
#prompt: 

#> $echo $BASH_VERSION


n_nodes=6
startsnap=21
endsnap=22 #set the same as startsnap if you just want to do one snapshot
model_dir='/home/desika/Dropbox/powderday/pd_runs/m13_mr_Dec16_2013' 
hydro_dir='/data/desika/gadgetruns/m13_mr_Dec16_2013' 


 
for (( i=$startsnap; i<=$endsnap; i++ ))


do

    echo "processing snapshot:  $i"


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
    
    echo "hydro_dir = '$hydro_dir/snapdir_'+snapnum_str+'/'">>$filem

    echo "Gadget_snap_name = 'snapshot_'+snapnum_str+'.0.hdf5'" >>$filem

    echo -e "\n" >>$filem

    echo "#where the files should go" >>$filem
    echo "PD_output_dir = '${model_dir}/' ">>$filem
    echo "Auto_TF_file = 'snap'+snapnum_str+'.logical' ">>$filem
    echo "Auto_dustdens_file = 'snap'+snapnum_str+'.dustdens' ">>$filem

    echo -e "\n\n" >>$filem
    echo "#===============================================" >>$filem
    echo "#FILE I/O" >>$filem
    echo "#===============================================" >>$filem
    echo "inputfile = PD_output_dir+'/example.'+snapnum_str+'.rtin'" >>$filem
    echo "outputfile = PD_output_dir+'/example.'+snapnum_str+'.rtout'" >>$filem

    
    


   

done