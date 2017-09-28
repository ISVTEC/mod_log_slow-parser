# mod_log_slow-parser

Parses the output of Apache mod_log_slow and produce statistics in CSV format.

# Usage

```
sudo apt-get install libtext-csv-perl
git clone git@github.com:ISVTEC/mod_log_slow-parser.git
mod_log_slow-parser/parse_mod_log_slow /var/log/apache2/mod_slow.log
```

Locally open the CSV files:

```
rsync -aPz HOST:mod_log_slow-parser/cpu-by-*.csv /tmp
open /tmp/cpu-by-*.csv
```
