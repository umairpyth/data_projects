select *
from [Portfolio Project]..['Covid-Deaths$']

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..['Covid-Deaths$']

--looking at total cases vs total death

select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from [Portfolio Project]..['Covid-Deaths$']
where location like '%states%'
order by 1,2

-- looking at the total cases vs popultion
select location, date,total_cases,population,(total_cases/population)*100 as deathpercentage
from [Portfolio Project]..['Covid-Deaths$']
where location like '%states%'
order by 1,2


-- looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestinfectioncount,max((total_cases/population)*100) as percentagepopulationinfected
from [Portfolio Project]..['Covid-Deaths$']
group by location, population
order by percentagepopulationinfected desc


--looking for countries with the highest deathcount per population
select location,max(cast(total_deaths as int)) as totalDeathCount
from [Portfolio Project]..['Covid-Deaths$']
where continent is not null	
group by location
order by totalDeathCount desc


---lets break it down by continent

select continent, max(cast(total_deaths as int)) as totalDeathCount
from [Portfolio Project]..['Covid-Deaths$']
where continent is not null	
group by continent
order by totalDeathCount desc


--- global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from [Portfolio Project]..['Covid-Deaths$']
where continent is not null
--group by date
order by 1,2

---number of cases everyday
select date, sum(new_cases) as newcasess
from [Portfolio Project]..['Covid-Deaths$']
--where continent is not null
group by date
order by newcasess desc

--looking at total population vs total vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RolingPeopleVaccinated
from [Portfolio Project]..['Covid-Deaths$'] dea
join [Portfolio Project]..[CovidVaccination$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RolingPeopleVaccinated
from [Portfolio Project]..['Covid-Deaths$'] dea
join [Portfolio Project]..[CovidVaccination$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..['Covid-Deaths$'] dea
join [Portfolio Project]..[CovidVaccination$] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualization

create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..['Covid-Deaths$'] dea
join [Portfolio Project]..[CovidVaccination$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
