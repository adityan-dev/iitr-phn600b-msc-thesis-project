set terminal pngcairo size 1024,768 enhanced font "Verdana,10"

plot_root_path = ARG1
data_root_path = ARG2
global_data_path = ARG3
data_path = sprintf("%s/%s", data_root_path, ARG4)
plot_path = sprintf("%s/%s", plot_root_path, ARG4)
system(sprintf("mkdir -p %s", plot_path))

inp_file = sprintf("%s%s", data_path, "/temperature.dat")
   out_file = sprintf("%s%s", plot_path, "/temperature.png")
   set title "Ensemble Temperature"
   set xlabel "Simulation Steps"
   set ylabel "Temperature"
   set output out_file
   g(x) = 0.695871
   plot inp_file using 1:2 skip 2 with lines title "Temperature", \
        g(x)  with lines lw 2 title "Fitted T"

inp_file = sprintf("%s%s", data_path, "/pressure.dat")
   out_file = sprintf("%s%s", plot_path, "/pressure.png")
   set title "Ensemble Pressure"
   set xlabel "Simulation Steps"
   set ylabel "Pressure"
   set output out_file
   plot inp_file using 1:2 skip 2 with lines title "Pressure"

inp_file = sprintf("%s%s", data_path, "/momentum.dat")
   out_file = sprintf("%s%s", plot_path, "/momentum.png")
   set title "Ensemble Momentum"
   set xlabel "Simulation Steps"
   set ylabel "Momentum"
   set output out_file
   plot inp_file using 1:2 skip 2 with lines title "Momentum"

   ensemble_mass = 1200 * (0.67 * 0.57 + 0.33 * 1.0)

   out_file = sprintf("%s%s", plot_path, "/com_velocity.png")
   set title "Ensemble Centre of Mass Velocity"
   set xlabel "Simulation Steps"
   set ylabel "COM Velocity"
   set output out_file
   plot inp_file using 1:($2/ensemble_mass) skip 2 with lines title "COM Velocity"

inp_file = sprintf("%s%s", data_path, "/energy.dat")
   out_file = sprintf("%s%s", plot_path, "/energy.png")
   set title "Ensemble Energies"
   set xlabel "Simulation Steps"
   set ylabel "Energy"
   set output out_file
   plot inp_file using 1:2 skip 2 with lines title "Kinetic Energy", \
        inp_file using 1:3 skip 2 with lines title "Potential Energy", \
        inp_file using 1:($2+$3) skip 2 with lines title "Total Energy"

x0 = 2.84 # Amstrong

inp_file = sprintf("%s%s", data_path, "/rdf_11.dat")
rdf_data = sprintf("%s%s", global_data_path, "/ntw_rdf/rdf_11_ntw.txt")
   out_file = sprintf("%s%s", plot_path, "/rdf_11.png")
   set title "Partial Radial Distribution Function Si - Si"
   set xlabel "r"
   set ylabel "RDF"
   set output out_file
   plot inp_file using 2:3 skip 4 with lines title "RDF Simulation", \
        rdf_data using ($1/x0):2 with points title "RDF Paper"

inp_file = sprintf("%s%s", data_path, "/rdf_12.dat")
rdf_data = sprintf("%s%s", global_data_path, "/ntw_rdf/rdf_12_ntw.txt")
   out_file = sprintf("%s%s", plot_path, "/rdf_12.png")
   set title "Partial Radial Distribution Function Si - O"
   set xlabel "r"
   set ylabel "RDF"
   set output out_file
   plot inp_file using 2:3 skip 4 with lines title "RDF Simulation", \
        rdf_data using ($1/x0):2 with points title "RDF Paper"

inp_file = sprintf("%s%s", data_path, "/rdf_22.dat")
rdf_data = sprintf("%s%s", global_data_path, "/ntw_rdf/rdf_22_ntw.txt")
   out_file = sprintf("%s%s", plot_path, "/rdf_22.png")
   set title "Partial Radial Distribution Function O - O"
   set xlabel "r"
   set ylabel "RDF"
   set output out_file
   plot inp_file using 2:3 skip 4 with lines title "RDF Simulation", \
        rdf_data using ($1/x0):2 with points title "RDF Paper"

inp_file = sprintf("%s%s", data_path, "/velocity_dist.dat")
   hist_file = sprintf("%s%s", data_path, "/velocity_dist_hist.dat")
   out_file = sprintf("%s%s", plot_path, "/velocity_dist.png")
   binwidth = 0.2
   bin(x, width) = width * floor(x/width) + width/2.0
   set table hist_file
   plot inp_file using ((v = sqrt($2*$2+$3*$3+$4*$4)) > 0 ? bin(v, binwidth) : 1/0):(1.0) skip 9 smooth frequency
   unset table
   #MB(v) = A * v**2 * exp(-v**2 / (2*T))
   MB(v) = A * sqrt(2/pi) * T**(-1.5) * v**2 * exp(-v**2 / (2*T))
   A = 100
   T = 0.7
   #fit MB(x) hist_file using 1:2 via T
   fit MB(x) hist_file using 1:2 via A, T
   set style fill solid 0.5 border -1
   set boxwidth binwidth
   set title "Velocity Distribution"
   set xlabel "v"
   set ylabel "Frequency"
   set output out_file
   plot hist_file using 1:2 with boxes title "Velocity Distribution", \
        MB(x) with lines lw 2 title "Maxwell Boltzman Fit"
