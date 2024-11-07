OC_STORE_URL = https://liveopencart.ru/img/ocStore-3.0.3.7_liveopencart.zip

setup: 	download_oc_store \
		install_oc_store \
		open_chrome

open_chrome:
	nohup xdg-open http://localhost:8000

download_oc_store:
	@echo "Downloading ocstore-3..."
	rm -rf src
	mkdir src
	cd src \
	&& wget $(OC_STORE_URL) \
	&& echo "Unzipping..."	\
	&& unzip -q ocStore-3.0.3.7_liveopencart.zip \
	&& echo "Moving files..." \
	&& rsync -a --remove-source-files ./OCStore-LiveOpencart-main/* ./ \
	&& echo "Clearing..." \
	&& rm ocStore-3.0.3.7_liveopencart.zip \
	&& rm -rf OCStore-LiveOpencart-main \
	chmod -R 775 src
	@echo "Completed."

install_oc_store:
	@echo "Setup ocStore3"
	docker compose down
	docker compose up -d
	./scripts/wait_for_containers.sh
	./scripts/wait_for_mysql.sh
	docker compose exec web bash -c '\
	cd /web/upload/install; \
	php cli_install.php install \
		--db_hostname mysql \
		--db_username root \
		--db_password secret \
		--db_database ocstore3 \
		--db_driver mysqli \
		--db_port 3306 \
		--username admin \
		--password admin \
		--email youremail@example.com \
		--http_server http://localhost:8000/'
	mv src/upload/system/storage src/
	sed -i "s/DIR_SYSTEM \. 'storage\/'/'\/web\/storage\/'/g" src/upload/config.php
	sed -i "s/DIR_SYSTEM \. 'storage\/'/'\/web\/storage\/'/g" src/upload/admin/config.php
	rm -rf src/upload/install
	@echo "OcStore3 successfully installed."

start:
	docker compose up -d
	./scripts/wait_for_containers.sh
	./scripts/wait_for_mysql.sh

stop:
	docker compose down
