# -*- coding: utf-8 -*-
from django.contrib import admin
from django.contrib.auth.models import Group
from django.contrib.auth.admin import UserAdmin
from windyer_auth.models import windyerUser
from windyer_auth.forms import windyerUserCreationForm


# Register your models here.

class windyerUserAdmin(UserAdmin):
    add_form = windyerUserCreationForm
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'password1', 'password2')
        }),
    )
    fieldsets = (
        (u'基本信息', {'fields': ('username', 'password', 'email')}),
        (u'权限', {'fields': ('is_active', 'is_staff', 'is_superuser')}),
        (u'时间信息', {'fields': ('last_login', 'date_joined')}),
    )

admin.site.unregister(Group)
admin.site.register(windyerUser, windyerUserAdmin)
