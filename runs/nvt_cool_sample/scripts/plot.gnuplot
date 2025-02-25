set terminal pngcairo size 1024,768 enhanced font "Verdana,10"

plot_root_path = ARG1
data_root_path = ARG2
global_data_path = ARG3
sub_run = ARG4
data_path = sprintf("%s/%s", data_root_path, sub_run)
plot_path = sprintf("%s/%s", plot_root_path, sub_run)
system(sprintf("mkdir -p %s", plot_path))

inp_file = sprintf("%s%s", data_path, "/temperature.dat")
   out_file = sprintf("%s%s", plot_path, "/temperature.png")
   set title "Ensemble Temperature"
   set xlabel "Simulation Steps"
   set ylabel "Temperature"
   set output out_file
   plot inp_file every 1000 using 1:2 skip 2 with lines title "Temperature"

inp_file = sprintf("%s%s", data_path, "/pressure.dat")
   out_file = sprintf("%s%s", plot_path, "/pressure.png")
   set title "Ensemble Pressure"
   set xlabel "Simulation Steps"
   set ylabel "Pressure"
   set output out_file
   plot inp_file every 1000 using 1:2 skip 2 with lines title "Pressure"

inp_file = sprintf("%s%s", data_path, "/momentum.dat")
   out_file = sprintf("%s%s", plot_path, "/momentum.png")
   set title "Ensemble Momentum"
   set xlabel "Simulation Steps"
   set ylabel "Momentum"
   set output out_file
   plot inp_file every 1000 using 1:2 skip 2 with lines title "Momentum"

   ensemble_mass = 1200 * (0.67 * 0.57 + 0.33 * 1.0)

   out_file = sprintf("%s%s", plot_path, "/com_velocity.png")
   set title "Ensemble Centre of Mass Velocity"
   set xlabel "Simulation Steps"
   set ylabel "COM Velocity"
   set output out_file
   plot inp_file every 1000 using 1:($2/ensemble_mass) skip 2 with lines title "COM Velocity"

inp_file = sprintf("%s%s", data_path, "/energy.dat")
   out_file = sprintf("%s%s", plot_path, "/energy.png")
   set title "Ensemble Energies"
   set xlabel "Simulation Steps"
   set ylabel "Energy"
   set output out_file
   plot inp_file every 1000 using 1:2 skip 2 with lines title "Kinetic Energy", \
        inp_file every 1000 using 1:3 skip 2 with lines title "Potential Energy", \
        inp_file every 1000 using 1:($2+$3) skip 2 with lines title "Total Energy"

inp_file = sprintf("%s%s", data_path, "/energy.dat")
   out_file = sprintf("%s%s", plot_path, "/ke.png")
   set title "Ensemble Energies"
   set xlabel "Simulation Steps"
   set ylabel "Energy"
   set output out_file
   plot inp_file every 1000 using 1:2 skip 2 with lines title "Kinetic Energy"

inp_file = sprintf("%s%s", data_path, "/energy.dat")
   out_file = sprintf("%s%s", plot_path, "/pe.png")
   set title "Ensemble Energies"
   set xlabel "Simulation Steps"
   set ylabel "Energy"
   set output out_file
       plot inp_file every 1000 using 1:3 skip 2 with lines title "Potential Energy"

inp_file = sprintf("%s%s", data_path, "/energy.dat")
   out_file = sprintf("%s%s", plot_path, "/te.png")
   set title "Ensemble Energies"
   set xlabel "Simulation Steps"
   set ylabel "Energy"
   set output out_file
       plot inp_file every 1000 using 1:($2+$3) skip 2 with lines title "Total Energy"

file1 = sprintf("%s%s", data_path, "/temperature.dat")
file2 = sprintf("%s%s", data_path, "/energy.dat")
out_file = sprintf("%s%s", plot_path, "/TvsKE.png")
   set title "KE vs T"
   set xlabel "T"
   set ylabel "KE"
   set output out_file
skip      = 1000+2
stride    = 30000+10
T_file    =  sprintf("%s%s", data_path, "/temperature.dat")
KE_file   =  sprintf("%s%s", data_path, "/energy.dat")
T_avg_file  =  sprintf("%s%s", data_path, "/Tavg.dat")
KE_avg_file =  sprintf("%s%s", data_path, "/KEavg.dat")
avg_file    =  sprintf("%s%s", data_path, "/T_KE_avg.dat")

# Construct the awk command for the T file using sprintf
T_cmd = sprintf("awk 'NR>%d { sum+=$2; count++; if(count==%d){ print sum/%d; sum=0; count=0 } }' %s > %s", \
                skip, stride, stride, T_file, T_avg_file)
system(T_cmd)

# Construct the awk command for the KE file
KE_cmd = sprintf("awk 'NR>%d { sum+=$2; count++; if(count==%d){ print sum/%d; sum=0; count=0 } }' %s > %s", \
                 skip, stride, stride, KE_file, KE_avg_file)
system(KE_cmd)

# Combine the two averaged files into one using paste
paste_cmd = sprintf("paste %s %s > %s", T_avg_file, KE_avg_file, avg_file)
system(paste_cmd)
f(x) = a * x**m
m = 1  # Initial guess
a = 1  # Initial guess
fit f(x) avg_file using 1:2 via a, m
plot avg_file using 1:2 title "Averaged Data" with points, \
     f(x) title "Fit: KE_avg = T^m" with lines
