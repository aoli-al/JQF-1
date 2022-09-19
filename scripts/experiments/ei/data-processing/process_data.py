#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import pandas as pd
from visualize import *


DATASET = ["ant", "maven", "bcel", "rhino", "closure"]

ALGORITHM = ["zest-fast", "ei-fast"]

def generate(base_path: str):
    for dataset in DATASET:
        time_based_plot_data = []
        count_based_plot_data = []
        cov_data = {
            "algo": [],
            "type": [],
            "value": []
        }
        for algorithm in ALGORITHM:
            time_based_data_per_algo = []
            count_based_data_per_algo = []
            for idx in range(1, 2):
                path = os.path.join(base_path, f"{dataset}-{algorithm}-results-{idx}")
                if not os.path.exists(path):
                    break
                print(f"processing: {os.path.basename(path)}")

                time_based_data, count_based_data = process_plot_data(path)
                time_based_data_per_algo.append(time_based_data)
                count_based_data_per_algo.append(count_based_data)

                cov_all = process_cov_data(os.path.join(path, "cov-all.log"))
                cov_valid = process_cov_data(os.path.join(path, "cov-valid.log"))

                cov_data["algo"].append(algorithm)
                cov_data["type"].append("all")
                cov_data["value"].append(len(cov_all))
                cov_data["algo"].append(algorithm)
                cov_data["type"].append("valid")
                cov_data["value"].append(len(cov_valid))

            time_based_plot_data.extend([d for d in time_based_data_per_algo])
            count_based_plot_data.extend([d for d in time_based_data_per_algo])
        if not time_based_plot_data:
            continue
        out_folder = os.path.join(base_path, "figs")
        if not os.path.exists(out_folder):
            os.mkdir(out_folder)
        time_based_plot_data = pd.concat(time_based_plot_data, ignore_index=True, sort=False)
        count_based_plot_data = pd.concat(count_based_plot_data, ignore_index=True, sort=False)
        generate_total_coverage_bar(os.path.join(out_folder, f"{dataset}-cov.pdf"), cov_data)
        generate_total_inputs_over_time(os.path.join(out_folder, f"{dataset}-total_inputs.pdf"), time_based_plot_data)
        generate_valid_coverage_over_time(os.path.join(out_folder, f"{dataset}-valid-cov-time.pdf"), time_based_plot_data)
        generate_all_coverage_over_time(os.path.join(out_folder, f"{dataset}-all-cov-time.pdf"), time_based_plot_data)
        generate_valid_coverage_over_total_inputs(os.path.join(out_folder, f"{dataset}-valid-cov-input.pdf"), count_based_plot_data)
        generate_all_coverage_over_total_inputs(os.path.join(out_folder, f"{dataset}-all-cov-input.pdf"), count_based_plot_data)


def main():
    path = sys.argv[1]
    generate(path)

if __name__ == "__main__":
    main()
