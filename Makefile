
CSV=https://bostonopendata-boston.opendata.arcgis.com/datasets/boston::primary-street-trees-public.csv?outSR=%7B%22latestWkid%22%3A2249%2C%22wkid%22%3A102686%7D
GEOJSON=https://bostonopendata-boston.opendata.arcgis.com/datasets/boston::primary-street-trees-public.geojson?outSR=%7B%22latestWkid%22%3A2249%2C%22wkid%22%3A102686%7D

trees.csv:
	wget -O $@ $(CSV)

trees.geojson:
	wget -O $@ $(GEOJSON)

trees.db:
	pipenv run sqlite-utils create-database $@ --enable-wal --init-spatialite

update: trees.db trees.geojson
	pipenv run geojson-to-sqlite trees.db trees trees.geojson --spatialite --pk GlobalID_2
	pipenv run sqlite-utils create-spatial-index trees.db trees geometry

run:
	# this will fail if no databases exist
	pipenv run datasette serve *.db -m metadata.yml --load-extension spatialite

clean:
	rm -f trees.csv trees.geojson
