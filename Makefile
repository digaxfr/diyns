tests:
	coverage run --omit='test_*.py,__init__.py' -m unittest discover
	coverage report -m
