#~*~coding: utf8~*~
"""
Stats dumped from the nflgame module
"""

from __future__ import print_function
import nflgame
import os
from sys import argv, stderr
from datetime import date
try:
    from functools import lru_cache
except ImportError:
    from backports.functools_lru_cache import lru_cache

# Time parameters
start_week = 1
start_year = 2009

# NFLGames "kind" constants, describing pre-, post-, and regular season games.
REG = "REG"
PRE = "PRE"
POST = "POST"


def csv_filename(dirname, season, week=None, kind=REG):
    """
    Get an OS-specific CSV filename for the season, the week number, and
    whether this is a post/pre/reg season game. Week need not be specified.
    """
    fn = "%d-season" % season

    if week is not None:
        fn += "-week%02d" % week

    fn += "-%s" % kind.lower()

    return os.path.join(dirname, fn + ".csv") 


@lru_cache(maxsize=128)
def _get_stats(season, week, kind):
    """
    Memoized stats getter. Requires fully-specified arguments to make effective
    use of the cache.
    """
    games = nflgame.games(season, week=week, kind=kind)
    return nflgame.combine_max_stats(games)


def get_stats(season, week=None, kind=REG):
    """
    Get a stats iterator for the given season, week (optional), optionally in
    the kind (post, pre, regular season).
    """
    return _get_stats(season, week, kind)


def has_stats(season, week=None, kind=REG):
    """
    Check if the season/week/kind combination exists.
    """
    has_error = False
    try:
        get_stats(season, week=week, kind=kind)
    except:
        has_error = True
    finally:
        return not has_error


def week_id(week):
    """
    Convenience function to interpret 0 as None to use a consistent
    enumeration for season vs. week-level aggregation.
    """
    return week if week is not 0 else None


if __name__ == "__main__":
    this_year = date.today().year

    out_dir = argv[1]

    if out_dir is None:
        raise Exception("Need to specify output directory")

    if not os.path.exists(out_dir):
        raise Exception("Output directory needs to exist")

    # TODO the stats dump could be configurable
    print("Dumping all stats for all years at all aggregations", file=stderr)
    # Get all seasons up to the current year
    for year in xrange(start_year, this_year + 1):
        print("-" * 80, file=stderr)
        print(" > Year: ", year, file=stderr)
        # Get all kinds, pre-, regular, and post-season
        for kind in [PRE, REG, POST]:
            print("   + Kind: ", kind, file=stderr)
            # Get full kind and week-level aggregations for all stats
            week = 0
            while has_stats(year, week=week_id(week), kind=kind):
                wkid = week_id(week)
                print("     - Week: ", wkid, file=stderr)
                fn = csv_filename(out_dir, year, week=wkid, kind=kind)
                print("       File: ", fn, file=stderr)
                statsgen = get_stats(year, week=wkid, kind=kind)
                statsgen.csv(fn)
                week += 1
