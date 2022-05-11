# LFTP JEODPP

Bash script to send files from your local computer to jeodpp server


## Authors
- [@menta78](https://github.com/menta78)
- [@ggarcias](https://www.github.com/ggarcias)
## Installation

- Credentials to access JEODPP Cloud
- lftp 

Install lftp:

We recommend to use lftp from anaconda

```bash
conda install -c conda-forge lftp 
```
    
## Usage/Examples

```bash
chmod +x ftp_put_files.sh
./ftp_put_files.sh --file data/schout*nc
```


## License

[MIT](https://choosealicense.com/licenses/mit/)

