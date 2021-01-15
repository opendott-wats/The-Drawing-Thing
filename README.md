# Notes


Calculating steps

- observed a memory issue when computing steps data in iOS; reason is the interval set to seconds; results in to many entries
    - how to solve this?
        - practical: use a coarser interval
        - practical: precompute in a different app reacting for shorter durations
        - conceptual: