from django.core.management.base import BaseCommand
from django.core.management.utils import get_random_secret_key
from dotenv import find_dotenv, load_dotenv, set_key
from os import environ

class Command(BaseCommand):
	help = 'Generates new secret key, change only if compromised!'

	def handle(self, *args, **kwargs):
		dotenv_file = find_dotenv()
		load_dotenv(dotenv_file)

		environ["SECRET_KEY"] = get_random_secret_key()

		# Write changes to .env file
		set_key(dotenv_file, "SECRET_KEY", environ["SECRET_KEY"])

