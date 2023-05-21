from django.urls import path
from myapp.views import *

urlpatterns = [
	path('', home_view, name='home'),
    path('logout/', logout_view, name='logout'),
    path('register/', registration_view, name='register'),
    path('login/', login_view, name='login'),
]
