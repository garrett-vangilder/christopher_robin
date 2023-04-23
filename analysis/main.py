import logging
import os
from random import randint
from time import sleep
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns



logger = logging.getLogger(__name__)

logger.setLevel(logging.INFO)

logger.addHandler(logging.StreamHandler())

def main():
    """
    Main function for analysis
    """
    logger.info("create_clean_data::main()")

    # read json file into pandas dataframe
    df = pd.read_csv("../data/cleaned_data.csv")

    # print dataframe
    logger.info(df)

    # print dataframe info
    logger.info(df.info())

    # make created a datetime column
    df["created"] = pd.to_datetime(df["created"])

    # create stacked bars for each day by provider without unknown
    df.groupby([df["created"].dt.day, "provider"]).size().unstack().plot(kind="bar", stacked=True)
    plt.show()
    

    # create line graph for each unique requesting ip address by day
    unique_ip_by_day = df.groupby(df["created"].dt.day).requesting_ip.nunique().sort_index()
    ip_by_day_plot = sns.lineplot(data=unique_ip_by_day)
    ip_by_day_plot.set_title("Unique IP Addresses by Day")
    ip_by_day_plot.set_xlabel("Day")
    ip_by_day_plot.set_ylabel("Unique IP Addresses")
    plt.show()

    colors = ['#11E481', '#F14150', '#E3E3E3']

    # create bar graph for each provider stacked by classification
    df.groupby(["provider", "gn_classification"]).size().unstack().plot(kind="bar", stacked=True, color=colors)

    plt.show()

    # create table for each provider with top common malicious ip addresses
    most_common_malicious_ips = df[df["gn_classification"] == "malicious"].requesting_ip.value_counts().sort_values(ascending=False).head(5)

    # most common full_path
    most_common_full_path = df.full_path.value_counts().sort_values(ascending=False).head(5)

    _, ax = plt.subplots()

    ax.axis('off')
    # ax.table(cellText=most_common_malicious_ips.values.reshape(1, -1), colLabels=most_common_malicious_ips.index, loc='center')

    import pdb; pdb.set_trace()
    # increase font size
    plt.rcParams.update({'font.size': 22})
    ax.table(cellText=most_common_full_path.values.reshape(1, -1), colLabels=most_common_full_path.index, loc='center')

    plt.show()


    plt.close()

    

if __name__ == "__main__":
    main()
