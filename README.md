# radiobash

## Description

A lightweight script for managing and playing online radio stations, featuring filtering and playlist management capabilities.

## Playlist

The playlist, stored in the `radio_stations.txt` file, consists of several lines, each representing a radio station. A radio station is defined by five fields separated by pipe characters `|` as follows:

```
Station Name|URL|Country|Language|Genre
```

## Dependencies

- [bash](https://www.gnu.org/software/bash/)
- [awk](https://www.gnu.org/software/gawk/)
- [sed](https://www.gnu.org/software/sed/)
- [GNU core utilities:](https://www.gnu.org/software/coreutils/)
  - [sort](https://www.gnu.org/software/coreutils/sort)
  - [uniq](https://www.gnu.org/software/coreutils/uniq)
- [mpv](https://github.com/mpv-player/mpv)
