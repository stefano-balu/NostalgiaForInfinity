# -*- coding: utf-8 -*-
"""Utils that merge different config files, and generate an output config"""
import json
import sys

# needs to mantain this list updated because freqtrade handle these pairlists
# directly in code (from line 91 to 94 freqtrade.optimize.backtesting)
BACKTESTING_EXCLUDE = ['VolumePairList', 'PerformanceFilter']


def load_json(path: str) -> dict:
    with open(path, 'r') as f:
        # handle comments
        jsondata = ''.join(line for line in f if not line.strip().startswith('//'))
        return json.loads(jsondata)


def dump_json(data: dict, path: str) -> None:
    with open(path, 'w') as f:
        json.dump(data, f)


def make_config(exchange, strategy):
    main_config = load_json(f"user_data/config.json")
    blacklist_config = load_json(f"configs/blacklist-{exchange}.json")
    pairlist_config = load_json(f"configs/pairlist-volume-{exchange}-{main_config['stake_currency'].lower()}.json")

    if 'name' in main_config['exchange']:
        if main_config['exchange']['name'] != exchange:
            raise ValueError(
                f"Inconsistent configuration: declared env var EXCHANGE: '{exchange}' "
                f"while user_data/config.json declare exchange {main_config['exchange']['name']}"
            )

    if 'pair_blacklist' not in main_config['exchange']:
        main_config['exchange']['pair_blacklist'] = blacklist_config['exchange']['pair_blacklist']

    if 'pairlists' not in main_config:
        main_config['pairlists'] = pairlist_config['pairlists']

    # dump main conf
    dump_json(main_config, f"user_data/configs/config-{strategy}.json")

    # dump backtesting conf
    main_config['pairlists'] = [
        p for p in main_config['pairlists']
        if p['method'] not in ['StaticPairList', *BACKTESTING_EXCLUDE]
    ]
    main_config['pairlists'].insert(0, {'method': 'StaticPairList'})
    dump_json(main_config, f"user_data/configs/config-backtesting-{strategy}.json")


if __name__ == '__main__':
    config = make_config(sys.argv[1], sys.argv[2])
