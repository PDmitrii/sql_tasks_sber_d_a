import pandas as pd
import requests
import numpy as np
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt
import time
import os
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from pymorphy2 import MorphAnalyzer
from sklearn.metrics.pairwise import cosine_similarity

import nltk
nltk.download('stopwords')
from nltk.corpus import stopwords

page = 0
per_page = 100

url = f'https://api.hh.ru/vacancies?per_page={per_page}&page={page}'

res = requests.get(url)

vacancies = res.json()

vacancies_id = set({})

while 'items' in vacancies.keys():
    for i in range(len(vacancies['items'])):
        vacancies_id.add(vacancies['items'][i]['id'])

    page += 1

    url = f'https://api.hh.ru/vacancies?per_page={per_page}&page={page}'

    res = requests.get(url)

    vacancies = res.json()

    # print(url)

vacancies_id = list(vacancies_id)

# шаг для отладки
# print('Количество вакансий: {0}'.format(len(vacancies_id)))

# функция, удаляющая все символы, кроме букв, цифр, пробелов (а также группы пробелов), подчеркиваний, и приводящая слова к нормальной форме
def cleaner_1(s):
    morph = MorphAnalyzer()

    s = re.sub('\W', ' ', s)
    clean = []
    for token in s.split(' '):
        if token != '':
            clean.append(morph.normal_forms(token)[0])
    return ' '.join(clean)


cnt_vac = len(vacancies_id)

# собираем из вакансий необходимую информацию

agg_description = []

for i in range(len(vacancies_id[:cnt_vac])):

    url_one = f'https://api.hh.ru/vacancies/{vacancies_id[i]}'

    res_one = requests.get(url_one)

    vacancy = res_one.json()


    def ValExist(d, k):
        if k in d.keys() and d[k] is not None:
            return True
        else:
            return False


    if ValExist(vacancy, 'name'):
        name = vacancy['name']
    else:
        name = ''

    if ValExist(vacancy, 'area'):
        area = vacancy['area']['name']
    else:
        area = ''

    if ValExist(vacancy, 'salary'):
        rep = lambda x: 'рубль' if x == 'RUR' else 'валюта'
        currency = rep(vacancy['salary']['currency'])
    else:
        currency = ''

    if ValExist(vacancy, 'address'):
        if ValExist(vacancy['address'], 'city'):
            city = vacancy['address']['city']
        else:
            city = ''
        if ValExist(vacancy['address'], 'street'):
            street = vacancy['address']['street']
        else:
            street = ''
        if ValExist(vacancy['address'], 'building'):
            building = vacancy['address']['building']
        else:
            building = ''

        address = city + ' ' + street + ' ' + building
    else:
        address = ''

    if ValExist(vacancy, 'experience'):
        experience = vacancy['experience']['name']
    else:
        experience = ''

    if ValExist(vacancy, 'experience'):
        schedule = vacancy['schedule']['name']
    else:
        schedule = ''

    if ValExist(vacancy, 'employment'):
        employment = vacancy['employment']['name']
    else:
        employment = ''

    if ValExist(vacancy, 'description'):
        reg = r'</li>|<li>|<strong>|</strong>|<br />|</ul>|<ul>|</p>|<p>|<hr />|<ol>|<em>|</em>'
        description = re.sub(reg, '', vacancy['description'])
    else:
        description = ''

    if ValExist(vacancy, 'key_skills'):
        key_skills = ''
        for ks in vacancy['key_skills']:
            key_skills += ks['name'] + ' '
    else:
        key_skills = ''

    if ValExist(vacancy, 'specializations'):
        specializations = set({})
        for v in vacancy['specializations']:
            specializations.add(v['name'])
            specializations.add(v['profarea_name'])
        specializations = ' '.join(list(specializations))
    else:
        specializations = ''

    if ValExist(vacancy, 'professional_roles'):
        professional_roles = set({})
        for v in vacancy['professional_roles']:
            professional_roles.add(v['name'])
        professional_roles = ' '.join(list(professional_roles))
    else:
        professional_roles = ''

    if ValExist(vacancy, 'employer'):
        employer = vacancy['employer']['name']
    else:
        employer = ''

    if ValExist(vacancy, 'working_time_intervals'):
        working_time_intervals = set({})
        for v in vacancy['working_time_intervals']:
            working_time_intervals.add(v['name'])
        working_time_intervals = ' '.join(list(working_time_intervals))
    else:
        working_time_intervals = ''

    agg_vac = name + ' ' + area + ' ' + currency + ' ' + address + ' ' + experience + ' ' + schedule + ' ' + employment \
              + ' ' + description + ' ' + key_skills + ' ' + specializations + ' ' + professional_roles \
              + ' ' + employer + ' ' + working_time_intervals

    agg_description.append(cleaner_1(agg_vac))

dfvac = pd.DataFrame({'id_vacancies': vacancies_id[:cnt_vac], 'full_description': agg_description})

f=open('resume.txt','r',encoding='utf-8')
resume=f.read()
f.close()

resume=cleaner_1(resume)

# объединяем вакансии и резюме для единой векторизации
train_corpus=dfvac['full_description'].values
train_corpus=np.append(train_corpus,resume)

# добавляем стоп-слова для для исключения из мешка
stop=stopwords.words('russian')

# Проводим обучени для последюущего исключения из мешка
text_transformer=TfidfVectorizer(stop_words=stop)
text_transformer.fit(train_corpus)

# "векторизуем" вакансии
vectorized_vacancies=text_transformer.transform(dfvac['full_description'])

# "векторизуем" резюме
resume=[resume]
vectorized_resume=text_transformer.transform(resume)

# формируем датафрейм с кодом вакансии и косинусным расстоянием
TOP_sutable_vac=pd.DataFrame({'id_vacancies':dfvac['id_vacancies'].values,\
                              'cosine_metric':cosine_similarity(vectorized_vacancies,vectorized_resume).T[0]})

# сортируем вакансии по убыванию "близости" к резюме
TOP_sutable_vac.sort_values(by='cosine_metric',ascending=False,inplace=True)

# выбираем ТОП=10 вакансий и записываем их названия и описания в файл
f=open('TOP10_recommended_vacancies.txt','w')
TOP = 10
for i in range(TOP):
    url_one = f'https://api.hh.ru/vacancies/{TOP_sutable_vac.iloc[i, 0]}'

    res_one = requests.get(url_one)

    vacancy = res_one.json()
    f.write('{0}:\n{1} \n\n'.format(vacancy['name'], re.sub(reg, '', vacancy['description'])))
f.close()