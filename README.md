# Scan matcher

register scan with icp methods

# Usage
1. You need to install [TEASER++](https://github.com/MIT-SPARK/TEASER-plusplus) first. **Remember to build the MATLAB Binding**
2. Download the lovely bunny from [Stanford Scanning Repository](http://graphics.stanford.edu/data/3Dscanrep/)
3. Create `data` folder at the root of this repo (ignored by git) and move the `bunny` folder in `data`
4. run `benchmark/build_random_benchmark.m` to build the dataset.
5. modify line 2 in `exp_benchmark.m` to your TEASER PATH (like `/home/ssz990220/Project/TEASER-plusplus/build/matlab`)
6. run `exp_benchmark.m` to registry point cloud with different algorithms
7. run `benchmark_boxchart.m` to plot the result


# TODO list

[-] match scan with arms data (JAKA, ABB & UR)

> check Tool T

[ ] refine registration

> refine on manifold

[ ] try pseudo distance