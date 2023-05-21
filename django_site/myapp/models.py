from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
	pass

class UserDesc(models.Model):
	user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
	description = models.CharField(max_length=100, null=True)

	def __str__(self):
		return self.user.username

