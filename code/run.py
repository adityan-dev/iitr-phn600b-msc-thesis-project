#!/usr/bin/env python3

import sys
import os
import subprocess
from dotenv import load_dotenv

def main(args):
    load_dotenv()
    lammps_exec_path = os.getenv('LAMMPS_EXEC_PATH')
    lammps_exec = f"{lammps_exec_path}/lmp_mpi"
    runs_path = os.getenv('RUNS_PATH')
    global_data_path = os.getenv('DATA_PATH')
    plotter_path = os.getenv('PLOTTER_PATH')
    num_procs = os.getenv('NUM_PROCS')
    simulation_name = args[1]
    simulation_path = f"{runs_path}/{simulation_name}"
    simulation_data_path = f"{simulation_path}/data"
    simulation_plots_path = f"{simulation_path}/plots"
    simulation_script_path = f"{simulation_path}/scripts"
    lammps_input_script = f"{simulation_script_path}/input.lmp"

    lammps_variables = ['-var', 'global_data_path', global_data_path,
                        '-var', 'data_root_path', simulation_data_path,
                        '-var', 'simulation_path', simulation_path,
                        '-var', 'plots_path', simulation_plots_path,
                        '-var', 'script_path', simulation_script_path]

    lammps_args = []
    gnuplot_args = ['gnuplot', '-p', '-c', f"{simulation_script_path}/plot.gnuplot",
                    f'{simulation_plots_path}',
                    f'{simulation_data_path}',
                    f'{global_data_path}']

    if args[0] == "analyze":
        subprocess.run(gnuplot_args + args[2:])
    if args[0] == "run":
        subprocess.run(['mpirun', '-np', num_procs,
                        lammps_exec, '-in', lammps_input_script] +
                       lammps_variables + lammps_args + args[2:])



if __name__ == "__main__":
    main(sys.argv[1:])
