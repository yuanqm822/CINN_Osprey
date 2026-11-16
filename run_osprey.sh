#!/bin/bash
#SBATCH --job-name=osprey
#SBATCH --array=1-3                 # 1-N, N = number of lines in jobs.txt
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --output=logs/osprey_%A_%a.out
#SBATCH --error=logs/osprey_%A_%a.err

# ---------------- EDIT THESE ----------------
JOBS=jobs.txt                       # one Osprey job file (.m) per line, full paths
OSPREY_CMD=osprey                   # command name - to be confirmed on RACC
# --------------------------------------------

set -euo pipefail

module purge
module use /software/modules/CINN
module load osprey/2.9.0

JOB=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$JOBS")
if [ -z "$JOB" ] || [ ! -f "$JOB" ]; then
    echo "No job file on line ${SLURM_ARRAY_TASK_ID} of $JOBS (got: '$JOB')" >&2
    exit 1
fi

# Own MATLAB Runtime cache per job (avoids clashes when many jobs start together)
export MCR_CACHE_ROOT=${TMPDIR:-/tmp}/mcr_${USER}_${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}
export SINGULARITYENV_MCR_CACHE_ROOT=$MCR_CACHE_ROOT APPTAINERENV_MCR_CACHE_ROOT=$MCR_CACHE_ROOT
mkdir -p "$MCR_CACHE_ROOT"
trap 'rm -rf "$MCR_CACHE_ROOT"' EXIT

echo "Running Osprey job $JOB on $(hostname) at $(date)"
"$OSPREY_CMD" "$JOB"
echo "Finished at $(date)"
