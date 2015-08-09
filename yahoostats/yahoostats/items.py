# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class YahoostatsItem(scrapy.Item):
    # General information
    name = scrapy.Field()
    url = scrapy.Field() # Page info scraped from
    position = scrapy.Field()
    week = scrapy.Field()
    season = scrapy.Field() # Year
    postseason = scrapy.Field() # True or False
    team = scrapy.Field()
    games = scrapy.Field()
    yurl = scrapy.Field() # Yahoo stats URL (to player)

    # General offensive stats
    fum = scrapy.Field()
    fuml = scrapy.Field()

    # QB Stats
    qbrat = scrapy.Field()
    pass_comp = scrapy.Field()
    pass_att = scrapy.Field()
    pass_yds = scrapy.Field()
    pass_ypa = scrapy.Field() # yards per attempt
    pass_lng = scrapy.Field()
    pass_int = scrapy.Field()
    pass_td = scrapy.Field()
    sacked = scrapy.Field()
    sacked_yds = scrapy.Field()

    # QB / RB stats
    rush_att = scrapy.Field()
    rush_yds = scrapy.Field()
    rush_ypa = scrapy.Field() # yards per attempt
    rush_lng = scrapy.Field()
    rush_td = scrapy.Field()

    # RB / WR Stats
    rec = scrapy.Field()
    rec_tgt = scrapy.Field()
    rec_yds = scrapy.Field()
    rec_ypr = scrapy.Field() # yards per reception
    rec_lng = scrapy.Field()
    rec_td = scrapy.Field()

    # WR Stats
    kr = scrapy.Field()
    kr_yds = scrapy.Field()
    kr_avg = scrapy.Field()
    kr_lng = scrapy.Field()
    kr_td = scrapy.Field()
    pr = scrapy.Field()
    pr_yds = scrapy.Field()
    pr_avg = scrapy.Field()
    pr_lng = scrapy.Field()
    pr_td = scrapy.Field()

    # Kicker stats
    fgm = scrapy.Field()
    fga = scrapy.Field()
    fgpct = scrapy.Field()
    xpa = scrapy.Field()
    xpm = scrapy.Field()
    xppct = scrapy.Field()
    pts = scrapy.Field()
    range_0_19_m = scrapy.Field()
    range_0_19_a = scrapy.Field()
    range_20_29_m = scrapy.Field()
    range_20_29_a = scrapy.Field()
    range_30_39_m = scrapy.Field()
    range_30_39_a = scrapy.Field()
    range_40_49_m = scrapy.Field()
    range_40_49_a = scrapy.Field()
    range_50_plus_m = scrapy.Field()
    range_50_plus_a = scrapy.Field()
    range_lng = scrapy.Field() # longest made

    # Punter stats
    punt = scrapy.Field()
    punt_yds = scrapy.Field()
    punt_lng = scrapy.Field()
    punt_avg = scrapy.Field()
    punt_in20 = scrapy.Field()
    punt_in10 = scrapy.Field()
    punt_fc = scrapy.Field() # fair catch
    punt_tb = scrapy.Field() # touchbacks
    punt_blk = scrapy.Field()

    # Defensive stats
    tackles_solo = scrapy.Field()
    tackles_ast = scrapy.Field()
    tackles = scrapy.Field()
    sacks = scrapy.Field()
    sacks_ydsl = scrapy.Field() # yards lost
    interceptions = scrapy.Field()
    interceptions_yds = scrapy.Field()
    interceptions_td = scrapy.Field()
    misc_td = scrapy.Field() # all defensive tds
    misc_ffum = scrapy.Field() # forced fumbles
    misc_pd = scrapy.Field() # pass defended
    misc_sfty = scrapy.Field() # safeties
