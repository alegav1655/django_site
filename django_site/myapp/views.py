from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from myapp.forms import *
from django.contrib.auth.decorators import login_required

def registration_view(request):
	if request.method == 'POST':
		form = RegistrationForm(request.POST)
		if form.is_valid():
			form.save()
			username = form.cleaned_data.get('username')
			password = form.cleaned_data.get('password1')
			user = authenticate(username=username, password=password)
			login(request, user)
			return redirect('home')
	else:
		form = RegistrationForm()
	return render(request, 'registration/register.html', {'form': form})

def login_view(request):
	if request.user.is_authenticated:
		return redirect('home')
	if request.method == 'POST':
		form = LoginForm(request.POST)
		if form.is_valid():
			username = form.cleaned_data['username']
			password = form.cleaned_data['password']
			user = authenticate(request, username=username, password=password)
			if user is not None:
				login(request, user)
				return redirect('home')
			else:
				form.add_error(None, 'Invalid username or password.')
	else:
		form = LoginForm()
	return render(request, 'registration/login.html', {'form': form})

def home_view(request):
	if not request.user.is_authenticated:
		return render(request, 'home.html')

	user_desc, created = UserDesc.objects.get_or_create(user=request.user)
	if request.method == 'POST':
		form = UserDescForm(request.POST, instance=user_desc)
		if form.is_valid():
			form.save()
			return redirect('home')
	else:
		form = UserDescForm(instance=user_desc)

	return render(request, 'home.html', {'form': form, "user_desc": user_desc})

@login_required
def logout_view(request):
	logout(request)
	return redirect('login')

def page_not_found(request, exception):
    return render(request, '404.html', status=404)
