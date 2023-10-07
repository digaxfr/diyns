tests:
	coverage run --omit='test_*.py,__init__.py' -m unittest discover
	coverage report -m

test_container:
	coverage run --omit='test_*.py,__init__.py' -m unittest -k container
	coverage report -m diyns/container.py
