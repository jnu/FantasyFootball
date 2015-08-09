# -*- coding: utf-8 -*-
import re
import time
from scrapy.spider import BaseSpider
from selenium import webdriver

from yahoostats.items import YahoostatsItem


# Get the href of the (first) ANCHOR tag in the cell
def parse_href_from_cell(el):
    a = el.find_element_by_tag_name('a')
    return a.get_attribute('href')

# Create a function that splits the text of an element by the given delimiter,
# and use the specified column
def get_split(delim, field, postparser=str):
    def _splitter(el):
        val = el.text.strip()
        return postparser(val.split(delim)[field])
    return _splitter

first_dash_col = get_split("-", 0, int)
second_dash_col = get_split("-", 1, int)

# Create a function that conditions the column to use for a given field based
# on the total count of columns on the page
def lenswitch(if_len, thenv, elsev):
    def _switch(length=None):
        return thenv if length == if_len else elsev
    return _switch

ls_ffum = lenswitch(28, 15, 16)
ls_pd = lenswitch(28, 16, 17)
ls_td = lenswitch(28, 15, None)
ls_sfty = lenswitch(28, 18, None)

# constants
PLAYER_XPATH = '//tr[contains(@class, "ysprow")]'

FIELD_MAP = {

    # Common Stats

    "name": [0, str],
    "team": [1, str],
    "games": [2, int],
    "yurl": [0, parse_href_from_cell],

    # Position specific stats

    "QB": {
        "qbrat": [4, float],
        "pass_comp": [5, int],
        "pass_att": [6, int],
        "pass_yds": [7, int],
        "pass_ypa": [8, float],
        "pass_lng": [9, int],
        "pass_int": [10, int],
        "pass_td": [11, int],
        "rush_att": [13, int],
        "rush_yds": [14, int],
        "rush_ypa": [15, float],
        "rush_lng": [16, int],
        "rush_td": [17, int],
        "sacked": [19, int],
        "sacked_yds": [20, int],
        "fum": [22, int],
        "fuml": [23, int]
    },

    "RB": {
        "rush_att": [4, int],
        "rush_yds": [5, int],
        "rush_ypa": [6, float],
        "rush_lng": [7, int],
        "rush_td": [8, int],
        "rec": [10, int],
        "rec_tgt": [11, int],
        "rec_yds": [12, int],
        "rec_ypr": [13, float],
        "rec_lng": [14, int],
        "rec_td": [15, int],
        "fum": [17, int],
        "fuml": [18, int]
    },

    "WR": {
        "rec": [4, int],
        "rec_tgt": [5, int],
        "rec_yds": [6, int],
        "rec_ypr": [7, float],
        "rec_lng": [8, int],
        "rec_td": [9, int],
        "kr": [11, int],
        "kr_yds": [12, int],
        "kr_avg": [13, float],
        "kr_lng": [14, int],
        "kr_td": [15, int],
        "pr": [17, int],
        "pr_yds": [18, int],
        "pr_avg": [19, float],
        "pr_lng": [20, int],
        "pr_td": [21, int],
        "fum": [23, int],
        "fuml": [24, int]
    },

    "TE": {
        "rec": [4, int],
        "rec_tgt": [5, int],
        "rec_yds": [6, int],
        "rec_ypr": [7, float],
        "rec_lng": [8, int],
        "rec_td": [9, int],
        "rush_att": [11, int],
        "rush_yds": [12, int],
        "rush_ypa": [13, float],
        "rush_lng": [14, int],
        "rush_td": [15, int],
        "fum": [17, int],
        "fuml": [18, int]
    },

    "DE": {
        "tackles_solo": [4, int],
        "tackles_ast": [5, int],
        "tackles": [6, int],
        "sacks": [8, float], # yahoo gives float - why?
        "sacks_ydsl": [9, int],
        "interceptions": [11, int],
        "interceptions_yds": [12, int],
        "interceptions_td": [13, int],
        "misc_ffum": [ls_ffum, int],
        "misc_pd": [ls_pd, int],
        "misc_td": [ls_td, int],
        "misc_sfty": [ls_sfty, int]
    },

    "DT": {
        "tackles_solo": [4, int],
        "tackles_ast": [5, int],
        "tackles": [6, int],
        "sacks": [8, float], # yahoo gives float - why?
        "sacks_ydsl": [9, int],
        "interceptions": [11, int],
        "interceptions_yds": [12, int],
        "interceptions_td": [13, int],
        "misc_ffum": [ls_ffum, int],
        "misc_pd": [ls_pd, int],
        "misc_td": [ls_td, int],
        "misc_sfty": [ls_sfty, int]
    },

    "NT": {
        "tackles_solo": [4, int],
        "tackles_ast": [5, int],
        "tackles": [6, int],
        "sacks": [8, float], # yahoo gives float - why?
        "sacks_ydsl": [9, int],
        "interceptions": [11, int],
        "interceptions_yds": [12, int],
        "interceptions_td": [13, int],
        "misc_ffum": [ls_ffum, int],
        "misc_pd": [ls_pd, int],
        "misc_td": [ls_td, int],
        "misc_sfty": [ls_sfty, int]
    },

    "LB": {
        "tackles_solo": [4, int],
        "tackles_ast": [5, int],
        "tackles": [6, int],
        "sacks": [8, float], # yahoo gives float - why?
        "sacks_ydsl": [9, int],
        "interceptions": [11, int],
        "interceptions_yds": [12, int],
        "interceptions_td": [13, int],
        "misc_ffum": [ls_ffum, int],
        "misc_pd": [ls_pd, int],
        "misc_td": [ls_td, int],
        "misc_sfty": [ls_sfty, int]
    },

    "CB": {
        "tackles_solo": [4, int],
        "tackles_ast": [5, int],
        "tackles": [6, int],
        "sacks": [8, float], # yahoo gives float - why?
        "sacks_ydsl": [9, int],
        "interceptions": [11, int],
        "interceptions_yds": [12, int],
        "interceptions_td": [13, int],
        "misc_ffum": [ls_ffum, int],
        "misc_pd": [ls_pd, int],
        "misc_td": [ls_td, int],
        "misc_sfty": [ls_sfty, int]
    },

    "S": {
        "tackles_solo": [4, int],
        "tackles_ast": [5, int],
        "tackles": [6, int],
        "sacks": [8, float], # yahoo gives float - why?
        "sacks_ydsl": [9, int],
        "interceptions": [11, int],
        "interceptions_yds": [12, int],
        "interceptions_td": [13, int],
        "misc_ffum": [ls_ffum, int],
        "misc_pd": [ls_pd, int],
        "misc_td": [ls_td, int],
        "misc_sfty": [ls_sfty, int]
    },

    "K": {
        "range_0_19_m": [4, first_dash_col],
        "range_0_19_a": [4, second_dash_col],
        "range_20_29_m": [5, first_dash_col],
        "range_20_29_a": [5, second_dash_col],
        "range_30_39_m": [6, first_dash_col],
        "range_30_39_a": [6, second_dash_col],
        "range_40_49_m": [7, first_dash_col],
        "range_40_49_a": [7, second_dash_col],
        "range_50_plus_m": [8, first_dash_col],
        "range_50_plus_a": [8, second_dash_col],
        "fgm": [9, int],
        "fga": [10, int],
        "fgpct": [11, float],
        "range_lng": [12, int],
        "xpm": [14, int],
        "xpa": [15, int],
        "xppct": [16, float],
        "pts": [18, int]
    },

    "P": {
        "punt": [4, int],
        "punt_yds": [5, int],
        "punt_avg": [6, float],
        "punt_lng": [7, int],
        "punt_in20": [8, int],
        "punt_in10": [9, int],
        "punt_fc": [10, int],
        "punt_tb": [11, int],
        "punt_blk": [12, int]
    }

}


# http://sports.yahoo.com/nfl/stats/byposition?pos=QB&conference=NFL&year=season_2001&timeframe=Week1&qualified=0&sort=28&old_category=WR
def yahoo_sports_url(season=2001, week=1, postseason=False, position="QB"):
    wk = "&timeframe=Week%d" % week
    tf_tpl = "year=%sseason_%d%s"
    tf_params = ('post', season, '') if postseason else ('', season, wk)
    tf = tf_tpl % tf_params
    return "http://sports.yahoo.com/nfl/stats/byposition?pos=%s&conference=NFL&%s" % (position, tf)

# Get all seasons
def get_seasons(years):
    return list(set([int(year[:4]) for year in years]))

# Omit aggregated stats. Only get weekly stats
def get_good_weeks(weeks):
    return [int(w[-2:].strip()) for w in weeks if w[:4] == 'Week']

# Get all the URL combinations. There will be dupes because the week and
# postseason parameters are mutually exclusive. These should be filtered out
# by the scraper.
def all_url_combos(positions, years, weeks):
    for season in get_seasons(years):
        for postseason in [True, False]:
            for position in positions:
                for week in get_good_weeks(weeks):
                    yield yahoo_sports_url(season, week, postseason, position)


# Given a yahoo stats URL, parse the position being viewed
def get_position_from_url(url):
    pos_matches = re.search(r'pos=(\w+)(?:\&|$)', url)
    return pos_matches.group(1) if pos_matches else ''

# Given a yahoo stats URL, parse the week being viewed
def get_week_from_url(url):
    wk_matches = re.search(r'timeframe=Week(\d+)(?:\&|$)', url)
    return int(wk_matches.group(1)) if wk_matches else None

# Given a yahoo stats URL, parse the season being viewed
def get_season_from_url(url):
    s_matches = re.search(r'year=(?:post)?season_(\d\d\d\d)(?:\&|$)', url)
    return int(s_matches.group(1)) if s_matches else None

# Given a yahoo stats ULR, parse whether it is the postseason being viewed
def get_postseason_from_url(url):
    ps_matches = re.search(r'year=(post)?season_', url)
    return ps_matches.group(1) is not None


# Given a list of cells and a field ID, parse the field according to the
# spec defined above
def get_field(position, field, cells):
    # Get the tuple describing how to parse the value from cells
    spec = FIELD_MAP[field] if field in FIELD_MAP else FIELD_MAP[position][field]
    # Get the column number
    n = spec[0]
    # The column number can be passed as a "switch," or a function that accepts
    # any of several parameters that will condition
    if hasattr(n, '__call__'):
        n = n(length=len(cells))
    # Passing "None" for column number indicates that the field is not present
    if n is None:
        return
    # Get the parser
    parser = spec[1]
    # Get the value that should be passed to the parser - by default,
    # this will just be the cell
    parse_val = cells[n]
    if type(spec) is list:
        parser = spec[1]
        # If the parser is a type primitive, then apply it on the inner text
        # of the element, after a small bit of additional cleansing.
        if type(parser) is type:
            parse_val = parse_val.text.strip()
            if parse_val == 'N/A':
                parse_val = None
    # Execute the parser on the value to be parsed. If there is an error, the
    # unparsed value will be returned
    try:
        val = parser(parse_val)
    except:
        val = parse_val
    finally:
        return val




# Fill in an item with player info
def fill_player_info(item, pos, player_row_cells):
    general_fields = ['name', 'team', 'games']
    pos_fields = FIELD_MAP[pos].keys()
    for field in (general_fields + pos_fields):
        item[field] = get_field(pos, field, player_row_cells)




class NflSpider(BaseSpider):
    name = "yahoo-nfl"
    allowed_domains = ["sports.yahoo.com"]
    start_urls = [yahoo_sports_url()]

    def __init__(self):
        self.driver = webdriver.Firefox()
        self.visited = []

    def get_all_info(self, url):
        '''
        Given a response, create an Item containing all of the data contained on
        the page. This will be one Item per player listed.
        '''
        pos = get_position_from_url(url)
        week = get_week_from_url(url)
        season = get_season_from_url(url)
        postseason = get_postseason_from_url(url)

        player_rows = self.driver.find_elements_by_xpath(PLAYER_XPATH)
        for player_row in player_rows:
            item = YahoostatsItem()
            item['position'] = pos
            item['url'] = url
            item['week'] = week
            item['season'] = season
            item['postseason'] = postseason
            cells = player_row.find_elements_by_tag_name('td')
            # scrape the rest of the data, imperatively
            fill_player_info(item, pos, cells)
            yield item

    def get_url_combos(self):
        '''
        Inspect the positions, years, and weeks listed on the page and return
        a generator for all of the URLs it would be possible to generate based
        on these data.

        NB This is a naive generator that produces thousands of duplicate URLs.
        It assumes the scraper itself has an appropriate DupeFilter in place.
        '''
        x = lambda s: [e.text for e in self.driver.find_elements_by_xpath(s)]

        # Get URL params
        positions = x('//select[@name="pos"]/option')
        years = x('//select[@name="year"]/option')
        weeks = x('//select[@name="timeframe"]/option')

        return all_url_combos(positions, years, weeks)

    def __del__(self):
        self.driver.close()

    def parse(self, response):
        '''
        Parse a page, yield all URLs to parse next
        '''
        need_to_visit = [response.url]
        visited = set()

        while len(need_to_visit) > 0:
            url = need_to_visit.pop()
            self.driver.get(url)
            visited = set([url]) | visited
            time.sleep(1)

            # Scrape this page, yielding an Item for each player entry
            for item in self.get_all_info(url):
                yield item

            combos = set([new_url for new_url in self.get_url_combos()])

            # Get all the subsequent URLs to scrape.
            need_to_visit = list(combos - visited)
