# Running Osprey (MRS) on RACC (CINN)

> **Status: being tested.** Osprey and OspreyBIDS are installed as CINN modules, but the
> end-to-end test on RACC is not finished yet. Commands marked *to be confirmed* may
> change. Contact Simon before using this for a study.

[Osprey](https://schorschinho.github.io/osprey/) is an all-in-one toolbox for MR
spectroscopy (MRS) processing and quantification. It is installed on RACC (University
of Reading) as CINN modules from Neurodesk, compiled with the free MATLAB Runtime, so
you do **not** need MATLAB or a MATLAB licence.

| Tool | Module | What it is |
|------|--------|------------|
| Osprey | `osprey/2.9.0` | Osprey itself (GUI and job files) |
| OspreyBIDS | `ospreybids/4.2.1` | Runs Osprey on a BIDS dataset with MRS data |

**SPM:** Osprey uses SPM12 for coregistration and segmentation. It is built into the
Osprey containers, so you do **not** load the `spm26` module for Osprey (and should
not load both in one job — see Tips).

---

## 1. One-time setup

Add this line to the end of your `~/.bashrc` (skip if you already have it):

```bash
module use /software/modules/CINN
```

Then:

```bash
source ~/.bashrc
module avail osprey ospreybids
module help osprey/2.9.0
```

## 2. Osprey with a job file

Osprey is driven by a **job file** (`.m`) that lists your MRS data, the matching T1
images and the processing options. Start from one of Osprey's example job files
(e.g. `jobSDAT.m`, `jobTwix.m`, `jobPhilips.m`) and edit the paths and settings for
your data. See the Osprey documentation on job files.

Run it without the GUI (*command name to be confirmed*):

```bash
module load osprey/2.9.0
osprey /full/path/to/myJob.m
```

Outputs go to the folder set in the job file (`outputFolder`), including the
coregistration and segmentation results (from SPM), fitted spectra and a summary
table of metabolite estimates.

### Many datasets as Slurm jobs

`run_osprey.sh` runs one job file per array task. List the job files, one per line, in
`jobs.txt`, set `#SBATCH --array=1-N`, then:

```bash
mkdir -p logs
sbatch run_osprey.sh
```

### The GUI

`osprey` with no arguments opens the GUI. It needs `ssh -X` and is slow over a remote
connection; use it to inspect results rather than for processing many datasets.

## 3. OspreyBIDS

OspreyBIDS runs Osprey on a BIDS dataset in which the MRS data are in each subject's
`mrs/` folder, next to the T1w in `anat/`, for example:

```
sub-101/ses-01/anat/sub-101_ses-01_T1w.nii.gz
sub-101/ses-01/mrs/sub-101_ses-01_svs.nii.gz  (+ .json)
```

Usage and options (*to be confirmed on RACC*):

```bash
module load ospreybids/4.2.1
ospreybids --help
```

## 4. Testing the installation (admin)

Osprey's example data includes MRS data with T1 images, which exercises every step,
including the SPM segmentation:

```bash
cd /scratch5/$USER
git clone --depth 1 https://github.com/schorschinho/osprey.git osprey_test
ls osprey_test/exampledata
```

Edit an example job file's paths to point to `/scratch5/$USER/osprey_test/...`, then run
it as in section 2. Success means the output folder contains coregistration and
segmentation maps and a table of quantified metabolites.

## 5. Tips and troubleshooting

- **Don't load another container module in the same job** (e.g. `spm26` or `fmriprep`).
  Each container puts its own copies of common commands (`git`, `python`, ...) first on
  your `PATH`, so they can clash. Use `module purge` before loading Osprey. If `git`
  fails with a certificate error, check `which git`.
- **MATLAB Runtime cache errors** when many jobs start at once: `run_osprey.sh` gives
  each job its own cache in `/tmp` (`MCR_CACHE_ROOT`).
- **"File not found" for a path that exists:** the container can only see bound folders
  (`/software`, `/home`, `/storage`, `/scratch2`–`/scratch6`). Use full paths in job
  files.

## Documentation

- Osprey: <https://schorschinho.github.io/osprey/>
- Osprey source and example data: <https://github.com/schorschinho/osprey>
- MRS-BIDS: <https://bids-specification.readthedocs.io/en/stable/modality-specific-files/magnetic-resonance-spectroscopy.html>
- Neurodesk: <https://neurodesk.org>

Questions or problems: contact Dr Simon Yuan (simon.yuan@reading.ac.uk).
