SELECT location, count(distinct(location)) as totalcontinets
FROM CovidDeaths
where continent is null
group by location

--SELECT *
--FROM CovidVaccinations
--order by 3,4

Select location, date,total_cases, new_cases, total_deaths,population
from CovidDeaths

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeadthPercentage
from CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at total cases vs population
--What percentage of population got covid 
Select location, date, total_cases, population, (total_cases/population)*100
from CovidDeaths
Where location like '%states%'
order by 1,2

--countries with highest infection rates compared to popultaion
Select location,population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
group by location, population
order by PercentPopulationInfected DESC

--Showing Countries with Highest Death count per population
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
where continent is not null
group by location
order by HighestDeathCount DESC

--Let's break things down by continent
--Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount DESC

--Global numbers
--global total cases by location from max to min
Select location, SUM(new_cases) as globaltotalcases --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null and total_cases is not null
group by location 
order by 2 desc


--global total cases by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage  --as globaltotalcases --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
group by date
order by 1

--global total_cases, total_deaths, death_percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage  --as globaltotalcases --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null

--looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
--We need to create CTE because we cannot use CTE on a column we just created i.e. RollingPeopleVaccinated
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
DROP Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
Select *, (RollingPeopleVaccinated/population)*100
from #PercentpopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *
from PercentpopulationVaccinated