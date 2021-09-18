
include .env

TIMERANGE=${START}-${END}


all: docker-pull docker-compose-build docker-compose-up

docker-pull:
	docker-compose -f docker-compose-prod.yml pull

docker-compose-build:
	docker-compose -f docker-compose-prod.yml build

docker-compose-up: make-config
	docker-compose -f docker-compose-prod.yml up -d

start: make-config
	freqtrade trade \
		--strategy ${STRATEGY} \
		--config user_data/configs/config-${STRATEGY}.json \
		--logfile user_data/logs/freqtrade-${STRATEGY}.log \
		--db-url sqlite:///user_data/${STRATEGY}.sqlite

backtesting: make-config
	freqtrade backtesting \
		--strategy ${STRATEGY} \
		--config user_data/configs/config-backtesting-${STRATEGY}.json \
       	--max-open-trades ${MAX_OPEN_TRADES} \
       	--stake-amount ${STAKE_AMOUNT} \
		--timerange ${TIMERANGE} \
		--export trades \
		--export-filename=user_data/backtest_results/backtest-result-${EXCHANGE}-${STRATEGY}-${TIMEFRAME}-${TIMERANGE}.json

download-data: make-config
	freqtrade download-data \
		--config user_data/configs/config-backtesting-${STRATEGY}.json \
		--timerange ${TIMERANGE} \
		--timeframe ${TIMEFRAME} 1h 1d

plot-profit: make-config
	freqtrade plot-profit \
		--config user_data/configs/config-backtesting-${STRATEGY}.json \
		--timeframe ${TIMEFRAME} \
		--export-filename=user_data/backtest_results/backtest-result-${EXCHANGE}-${STRATEGY}-${TIMEFRAME}-${TIMERANGE}.json \
		--auto-open

setup-venv:
	pip install -r requirements.txt
	freqtrade install-ui

setup-repo:
	git remote add upstream https://github.com/iterativv/NostalgiaForInfinity.git
	git fetch upstream
	git checkout ${BRANCH}

make-config:
	@python tools/make_config.py ${EXCHANGE} ${STRATEGY}
