select *
from Portfolio_proj1..CovidDeaths$
order by 3,4


/*select *
from Portfolio_proj1..CovidDeaths$
order by 3,4
*/

-- select what we are using
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_proj1..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths
-- shows the likelihood of dying if you get affected by covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_proj1..CovidDeaths$
where location like '%states%'
order by 1,2

-- looking at total cases vs total population
-- shows what perentage of population got covid in your country

select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from Portfolio_proj1..CovidDeaths$
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rates compared to population
select location, max(total_cases) as HighestInfectionCount, population, max(total_cases/population)*100 as PercentPopInfected
from Portfolio_proj1..CovidDeaths$
group by location, population
order by PercentPopInfected desc

-- showing the countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_proj1..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Break things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_proj1..CovidDeaths$
where continent is not null		
group by continent
order by TotalDeathCount desc


-- showing the continent with higest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_proj1..CovidDeaths$
where continent is not null		
group by continent
order by TotalDeathCount desc


-- Global numbers

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_cases as int))/sum(cast(new_deaths as int))*100 as TotDeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_proj1..CovidDeaths$
where continent is not null 
--group by date
order by 1,2

-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio_proj1..CovidDeaths$ dea
Join Portfolio_proj1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_proj1..CovidDeaths$ dea
Join Portfolio_proj1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE (Common Table Expressions)
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_proj1..CovidDeaths$ dea
Join Portfolio_proj1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingPeopleVaccinated
from PopvsVac


-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_proj1..CovidDeaths$ dea
Join Portfolio_proj1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingPeopleVaccinated
from #PercentPopulationVaccinated


-- Creating view to store data for later visualization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_proj1..CovidDeaths$ dea
Join Portfolio_proj1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
