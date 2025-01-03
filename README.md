# GD - Gaussian Log File Parser

`gd` is a command-line interface (CLI) tool designed to help users parse Gaussian log files and extract selected data.

## Features

- Extract and display various properties from Gaussian log files, including:
  - Energy and ZPE corrected energy
  - HOMO and LUMO energies
  - Electric dipole moment
  - Polarizability
  - Hyperpolarizability
  - Point Group
  - Sum of Mulliken charges
  - Bond length distance matrix
  - Wilber Bond Order matrix
- Save IR and Raman Activity Spectrum data for further analysis.

## Usage

```bash
Usage: gd [OPTIONS] [FILE1]
```

### Options:

- `-a`, `--all`                           Show all items
- `-e`, `--zpe`                           Show Energy and ZPE corrected energy
- `-b`, `--homo-lumo`                     Show HOMO and LUMO energies
- `-d`, `--dipole-moment`                 Show electric dipole moment
- `-p`, `--polarizability`                Show polarizability
- `-P`, `--hyperpolarizability`           Show hyperpolarizability
- `-g`, `--point-group`                   Show Point Group
- `-s <len>`, `--sume-gas-charge <len>`   Show sum of Mulliken charge
- `-f`, `--freq`                          Save IR and Raman Activity Spectrum data in `gausssum/`
- `-B`, `--bond-length`                   Show Bond length distance matrix
- `-o`, `--bond-order`                    Show Wilber Bond Order matrix (input FCHK file)
- `-t`, `--no-title`                      Do not display titles
- `-h`, `--help`                          Display this help message

### Notes:

1. All displayed property values are printed as CSV at the bottom.
2. The CSV is in the order of the list above, not the options provided.
3. Use the sum of Mulliken charges cautiously, as it sums the last `<len>` elements from the input file.

## Frequency Analysis

To perform frequency analysis, `gd` utilizes the Python script `get_freqs.py`. You will need the following dependencies installed:

- `numpy`
- `cclib`

You can make the script executable using tools like `pyinstaller`. Ensure to provide the correct path for the executable in the `freq` section of the `gd` bash script.

## Wilber Bond Order Analysis

To print the Wilber bond order analysis information, ensure that the `Multiwfn` tool is available in your system's PATH.

## Future Suggestions

- Improve codebase cleanliness and organization.
- Add functionality for Density of States (DOS) analysis.
- Rewrite using an existing parser like `cclib` in Python (but the `cclib` parsed object does not have all required attributes yet).

## Contributing

Feel free to make a pull request with any changes or improvements you wish to make. Contributions are welcome!

## License

This project is licensed under the MIT License.
