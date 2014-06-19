# mod_log_slow-parser

Parses the output of Apache mod_log_slow and produce statistics in CSV format.

# Installation

```
sudo apt-get install libtext-csv-perl
```

# Usage

```
./parse_mod_log_slow.pl /var/log/apache2/mod_slow.log
```

This will produce the following files:

- cpu-by-site.csv
- cpu-by-url.csv

Which you can open with LibreOffice.
