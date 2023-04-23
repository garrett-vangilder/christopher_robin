import logging
import os
from random import randint
from time import sleep
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from requests import get


logger = logging.getLogger(__name__)

logger.setLevel(logging.INFO)

logger.addHandler(logging.StreamHandler())

# create dict of IP addresses and their corresponding cloud provider
cloud_providers = {
    "44.202.14.136": "AWS",
    "35.174.13.6": "AWS",
    "3.86.163.161": "AWS",
    "44.202.140.49": "AWS",
    "3.86.34.213": "AWS",
    "54.166.141.59": "AWS",
    "44.203.150.1": "AWS",
    "52.91.162.211": "AWS",
    "34.68.197.145": "GCP",
    "35.202.218.25": "GCP",
    "34.29.233.83": "GCP",
    "34.71.117.23": "GCP",
    "34.123.7.62": "GCP",
    "35.184.200.155": "GCP",
    "34.132.165.207": "GCP",
    "34.170.96.166": "GCP",
    "20.121.184.210": "Azure",
    "20.169.235.248": "Azure",
    "20.121.185.49": "Azure",
    "20.169.235.233": "Azure",
    "20.169.235.110": "Azure",
    "20.169.237.11": "Azure",
    "20.169.235.68": "Azure",
    "20.169.236.160": "Azure",
}

def get_gn_classification(ip):
    """
    Get the classification from greynoise for the ip address
    """
    sleep(randint(1, 2))
    logger.info("main::get_gn_classification()")

    # if ip is unknown, return unknown
    if ip == "Unknown":
        return "unknown"

    # get the classification from greynoise
    gn_classification = "unknown"
    try:
        url = f"https://api.greynoise.io/v3/community/{ip}"

        headers = {
            "accept": "application/json",
            "key": os.environ.get("GN_API_KEY")
        }

        response = get(url, headers=headers)
        if response.status_code == 200:
            gn_classification = response.json().get("classification")
        else:
            gn_classification = "unknown"
    except:
        gn_classification = "unknown"

    # return the classification
    return gn_classification


def main():
    """
    Main function for analysis
    """
    logger.info("create_clean_data::main()")

    # read json file into pandas dataframe
    df = pd.read_json("../data/data.json")

    # print dataframe
    logger.info(df)

    # print dataframe info
    logger.info(df.info())

    # print dataframe shape
    logger.info(df.shape)

    # print dataframe columns
    logger.info(df.columns)

    # print dataframe head
    logger.info(df.head())

    # print dataframe tail
    logger.info(df.tail())

    # print dataframe describe
    logger.info(df.describe())

    # fill missing values with 0
    df.fillna(0, inplace=True)
    
    # add provider column to dataframe from headers host column
    df["provider"] = df["headers"].apply(lambda x: cloud_providers.get(x.get("Host"), 'Unknown'))

    # print count for each provider
    logger.info(df["provider"].value_counts())

    # get ip addresses for unknown providers urls and try to figure out the provider, add as column
    df["ip"] = df[df["provider"] == "Unknown"]["url"].apply(lambda x: x.split("/")[2].split(":")[0])

    # use the ip address to get the provider if provider is currently unknown
    df["provider"] = df.apply(lambda x: cloud_providers.get(x["ip"], x["provider"]), axis=1)

    # print count for each provider
    logger.info(df["provider"].value_counts())

    # print unique unknown providers urls
    logger.info(df[df["provider"] == "Unknown"]["url"].unique())

    # make created a datetime column
    df["created"] = pd.to_datetime(df["created"])

    # add requesting_ip column to dataframe from headers host column
    df["requesting_ip"] = df["headers"].apply(lambda x: x.get("X-Forwarded-For", "Unknown"))

    # some unknowns may have the ip address as the X-Real-IP header
    df["requesting_ip"] = df.apply(lambda x: x.get('headers', {}).get('X-Real-Ip', 'Unknown') if x["requesting_ip"] == "Unknown" else x["requesting_ip"], axis=1)


    # limit to requests before April 22nd
    df = df[df["created"] < "2023-04-22"]

    # remove unknown provider
    df = df[df["provider"] != "Unknown"]

    # for each entry, call greynoise api to get the classification, and apply to gn_classification column
    for index, row in df.iterrows():
        df.at[index, "gn_classification"] = get_gn_classification(row["requesting_ip"])
    
    # save dataframe to csv
    df.to_csv("../data/cleaned_data.csv", index=False)


    # create stacked bars for each day by provider without unknown
    df[df["provider"] != "Unknown"].groupby([df["created"].dt.day, "provider"]).size().unstack().plot(kind="bar", stacked=True)
    plt.show()
    

    # create line graph for each unique requesting ip address by day
    unique_ip_by_day = df.groupby(df["created"].dt.day).requesting_ip.nunique().sort_index()
    ip_by_day_plot = sns.lineplot(data=unique_ip_by_day)
    ip_by_day_plot.set_title("Unique IP Addresses by Day")
    ip_by_day_plot.set_xlabel("Day")
    ip_by_day_plot.set_ylabel("Unique IP Addresses")
    plt.show()

    
    plt.close()
    # most requests by provider
    logger.info(df[df["provider"] != "Unknown"].groupby("provider").size().sort_values(ascending=False))

    

if __name__ == "__main__":
    main()
