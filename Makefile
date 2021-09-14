
include .env

TIMERANGE=${START}-${END}

start:
	freqtrade trade \
		--strategy ${STRATEGY} \
		--config user_data/configs/config-${STRATEGY}.json \
		--logfile user_data/logs/freqtrade-${STRATEGY}.log \
		--db-url sqlite:///user_data/${STRATEGY}.sqlite

backtesting:
	freqtrade backtesting \
		--strategy ${STRATEGY} \
		--config user_data/configs/config-backtesting-${STRATEGY}.json \
       	--max-open-trades ${MAX_OPEN_TRADES} \
       	--stake-amount ${STAKE_AMOUNT} \
		--timerange ${TIMERANGE} \
		--export trades \
		--export-filename=user_data/backtest_results/backtest-result-${EXCHANGE}-${STRATEGY}-${TIMEFRAME}-${TIMERANGE}.json

download-data:
	freqtrade download-data \
		--config user_data/configs/config-backtesting-${STRATEGY}.json \
		--timerange ${TIMERANGE} \
		--timeframe ${TIMEFRAME} \
		--timeframe 1h

plot-profit:
	freqtrade plot-profit \
		--config user_data/configs/config-backtesting-${STRATEGY}.json \
		--timeframe ${TIMEFRAME} \
		--export-filename=user_data/backtest_results/backtest-result-${EXCHANGE}-${STRATEGY}-${TIMEFRAME}-${TIMERANGE}.json \
		--auto-open

setup-venv:
	pip install -r requirements.txt
	freqtrade install-ui
