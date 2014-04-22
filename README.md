# mod_log_slow-parser

Parses the output of Apache mod_log_slow and produce statistics in CSV format.

# Installation

See the ``INSTALL'' file.

# Usage

```
./parse_mod_log_slow.pl /var/log/apache2/mod_slow.log
```

This will produce the following files:

- cpu-by-site.csv
- cpu-by-url.csv

Which you can open with LibreOffice.
