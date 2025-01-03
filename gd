#!/bin/bash

all=false
zpe=false
homo_lumo=false
dipole_moment=false
polarizability=false
hyperpolarizability=false
sume_gas_charge=false
sume_gas_charge_value=""
point_group=false
bond_length=false
bond_order=false
freq=false
file1=""

title=true


GREEN='\033[0;32m'
NC='\033[0m'
BOLDGREEN="\e[1;32m"

usage() {
    echo "Usage: gd [OPTIONS] [FILE1]"
    echo "Options:"
    echo "  -a, --all                           Show all items"
    echo "  -e, --zpe                           Show Energy and ZPE corrected energy"
    echo "  -b, --homo-lumo                     Show HOMO and LUMO energies"
    echo "  -d, --dipole-moment                 Show electric dipole moment"
    echo "  -p, --polarizability                Show polarizability"
    echo "  -P, --hyperpolarizability           Show hyperpolarizability"
    echo "  -g, --point-group                   Show Point Group"
    echo "  -s <len>, --sume-gas-charge <len>   Show sum of Mulliken charge"
    echo "  -f , --freq                         Save IR and Raman Activity Spectrum data in gausssum/"
    echo "  -B , --bond-length                  Show Bond length distance matrix"
    echo "  -o , --bond-order                   Show Wilber Bond Order matrix"
    echo "  -t, --no-title                      Do not display titles"
    echo "  -h, --help                          Display this help message"
    echo "--------------------------------------------------------------------------"
    echo "NOTE: "
    echo "1) All the diplayed property values are printed as CSV at the bottom"
    echo "2) The CSV is in the order of the list above, not the options provided"
    echo "3) Use sum of Mulliken charges cautiously, as it sums the last <len> elements from the input file"
    exit 0
}
# Using getopt to read the options
OPTIONS=$(getopt -o aebdPps:gftBoh --long all,zpe,homo-lumo,dipole-moment,polarizability,hyperpolarizability,sume-gas-charge:,point-group,freq,no-title,bond-length,bond-order,help -- "$@")
if [ $? -ne 0 ]; then
    usage
fi
eval set -- "$OPTIONS"

while true; do
    case "$1" in
        -a | --all )
            all=true
            shift
            ;;
        -e | --zpe )
            zpe=true
            shift
            ;;
        -b | --homo-lumo )
            homo_lumo=true
            shift
            ;;
        -d | --dipole-moment )
            dipole_moment=true
            shift
            ;;
        -p | --polarizability )
            polarizability=true
            shift
            ;;
        -P | --hyperpolarizability )
            hyperpolarizability=true
            shift
            ;;
        -s | --sume-gas-charge )
            sume_gas_charge=true
            sume_gas_charge_value="$2"
            shift 2
            ;;
        -g | --point-group )
            point_group=true
            shift
            ;;
        -f | --freq )
            freq=true
            shift
            ;;
        -B | --bond-length )
            bond_length=true
            shift
            ;;
        -o | --bond-order )
            bond_order=true
            shift
            ;;
        -t | --no-title )
            title=false
            shift
            ;;
        -h | --help )
            usage
            ;;
        -- )
            shift
            break
            ;;
        * )
            echo "Error: Invalid option $1"
            usage
            ;;
    esac
done

# Handle file arguments
if [[ $# -gt 1 ]]; then
    echo "Error: Too many files specified."
    usage
elif [[ $# -eq 1 ]]; then
    file1="$1"
fi


# ================================================================================================================================
# What all to be displayed stored as array
display=()

if [ "$zpe" = true ] || [ "$all" = true ]; then
  Energy=$(grep Done $file1 | tail -n 1 | sed 's/.*=\s*\(-*[0-9.]*\)\s*.*/\1/')
  eV=$(echo "scale=20; $Energy * 27.211324570273" | bc)
  
  #ZPE corrected energy
  ZPE_cor_EE=$(grep ' Sum of electronic and zero-point Energies' $file1 | sed ' s: Sum of electronic and zero-point Energies=          ::')
  ZPE_eV=$(echo "scale=20; $ZPE_cor_EE * 27.211324570273" | bc)
  
  display+=("$ZPE_eV")
  if [ "$title" = true ]; then 
    echo "Energy = $Energy A.U"
    printf "= ${GREEN} $eV eV ${NC} \n"
    echo "ZPE corrected Energy = $ZPE_cor_EE A.U"
    printf "= ${GREEN} $ZPE_eV eV ${NC} \n"
  fi
fi

  
  
if [ "$homo_lumo" = true ] || [ "$all" = true ]; then 
  # ALPHA
  read alpha_first_value alpha_last_value < <(tac $file1 | grep 'eigenvalues --' | grep -m1 -B 1 'Alpha  occ.' | awk 'NR==1 {first_value=$5} NR==2 {last_value=$NF} END {print first_value, last_value}')
  alpha_homo=$(echo "scale=20; $alpha_last_value * 27.211324570273" | bc)
  alpha_lumo=$(echo "scale=20; $alpha_first_value * 27.211324570273" | bc)
  
  # BETA
  beta_homo=-10000
  beta_lumo=10000
  if grep -q "Beta  occ." $file1; then
  	read beta_first_value beta_last_value < <(tac $file1 | grep 'eigenvalues --' | grep -m1 -B 1 'Beta  occ.' | awk 'NR==1 {first_value=$5} NR==2 {last_value=$NF} END {print first_value, last_value}')
  	beta_homo=$(echo "scale=20; $beta_last_value * 27.211324570273" | bc)
  	beta_lumo=$(echo "scale=20; $beta_first_value * 27.211324570273" | bc)
  fi
  
  if (( $(echo "$alpha_homo > $beta_homo" | bc -l) )); then
  	HOMO=$alpha_homo
  else
  	HOMO=$beta_homo
  fi
  
  if (( $(echo "$beta_lumo > $alpha_lumo" | bc -l) )); then
  	LUMO=$alpha_lumo
  else
  	LUMO=$beta_lumo
  fi

  display+=("$HOMO")
  display+=("$LUMO")


  if [ "$title" = true ]; then
    echo "Alpha HOMO: $alpha_last_value A.U"
    echo "= $alpha_homo eV"
    echo "--------------------------------------------------------"
    echo "Alpha LUMO: $alpha_first_value A.U"
    echo "= $alpha_lumo eV"
    echo
    if grep -q "Beta  occ." $file1; then
    	echo "Beta HOMO: $beta_last_value A.U"
    	echo "= $beta_homo eV"
    	echo "--------------------------------------------------------"
    	echo "Beta LUMO: $beta_first_value A.U"
    	echo "=$beta_lumo eV"
    	echo
    fi
    echo "========================================================"
    printf "HOMO:  ${GREEN} $HOMO eV ${NC} \n"
    printf "LUMO:  ${GREEN} $LUMO eV ${NC} \n"
    band_gap=$(echo "$LUMO - $HOMO" | bc)
    printf "Band gap:  ${BOLDGREEN} $band_gap eV ${NC} \n"
    echo "========================================================"
    echo
  fi
fi


if [ "$dipole_moment" = true ] || [ "$all" = true ]; then 
  dm=$(printf "%10.10f" $(tac $file1 | grep -m 1 "Electric dipole moment" --before-context 3 | head -n 1 | awk '{print $3}' | sed 's/D/e/'))

  display+=("$dm")
  
  if [ "$title" = true ]; then
    echo "The Dipole moment: "
    printf " = ${GREEN} $dm debye ${NC} \n"
  fi
fi


if [ "$polarizability" = true ] || [ "$all" = true ]; then 
  pol=$(printf "%10.10f" $(tac $file1 | grep -m 1 " iso" | awk '{print $2}'| sed 's/D/e/'))

  display+=("$pol")

  if [ "$title" = true ]; then
    echo "The Polarizability: "
    printf " = ${GREEN} $pol a.u ${NC} \n"
  fi
fi


if [ "$hyperpolarizability" = true ] || [ "$all" = true ]; then 
  arr=("xxx" "xxy" "yxy" "yyy" "xxz" "yxz" "yyz" "zxz" "zyz" "zzz")
  vals=()
  for i in "${arr[@]}"; do
    result=$(printf "%10.10f" $(tac "$file1" | grep -m 1 "$i" | awk '{print $2}'| sed 's/D/e/'))
      vals+=("$result")
  done
  
  hyppol=$(echo "sqrt((${vals[0]} + ${vals[2]} + ${vals[7]})^2 + (${vals[3]} + ${vals[1]} + ${vals[8]})^2 + (${vals[9]} + ${vals[4]} + ${vals[6]})^2)" | bc)

  display+=("$hyppol")

  if [ "$title" = true ]; then
    echo "The Hyperpolarizability: "
    printf " = ${GREEN} $hyppol a.u ${NC} \n"
  fi
fi


if [ "$point_group" = true ] || [ "$all" = true ]; then
  pg=$(tac $file1 | grep -m 1 "point group" | awk '{print $4}')

  display+=("$pg")
  if [ "$title" = true ]; then
    echo "The Point Group of the system: "
    printf " = ${GREEN} $pg ${NC} \n"
  fi
fi

if [ "$sume_gas_charge" = true ]; then #  || [ "$all" = true ]
  mul=$(tac $file1 | grep -E "Mulliken .* hydrogens" -m 1 -A $(echo "$sume_gas_charge_value + 1" | bc) | tail -n $sume_gas_charge_value | awk '{s+=$3} END {print s}')

  nbo=$(tac $file1 | grep "Natural Population" -m 1 -A $(echo "$sume_gas_charge_value" + 3 | bc) | tail -n $sume_gas_charge_value | awk '{s+=$3} END {print s}')

  display+=("$mul")

  #display+=("$mul")
  if [ "$title" = true ]; then
    echo "Sum of Mulliken charges of:"
    tac $file1 | grep -E "Mulliken .* hydrogens" -m 1 -A $(echo "$sume_gas_charge_value + 1" | bc) | tail -n $sume_gas_charge_value | awk '{ printf "%s", $2 }'
    echo
    printf " = ${GREEN} $mul ${NC} \n\n"
    echo "Sum of NBO charges of:"
    tac $file1 | grep "Natural Population" -m 1 -A $(echo "$sume_gas_charge_value" + 3 | bc) | tail -n $sume_gas_charge_value | awk '{ printf "%s", $1 }'
    echo
    printf " = ${GREEN} $nbo ${NC} \n\n"
  fi
fi

if [ "$freq" = true ]; then 
  fullfile=$(echo $PWD"/"$file1)
  START=0 
  END=4000
  NUMPTS=16000
  /home/karet/Documents/Research/Msc/scripts/get_freq_gausssum/dist/get_freq $fullfile $START $END $NUMPTS

fi

if [ "$bond_order" = true ]; then 
  echo -e "9\n1\n" | Multiwfn $file1
fi

if [ "$bond_length" = true ]; then 
  awk '/Distance matrix/, /Stoichiometry/' "$file1" | tac | sed '/Distance matrix/q' | tac
fi


# Display all items of diplay array as comma seperated values 
printf "%s\n" "${display[@]}" | paste -sd ',' -
