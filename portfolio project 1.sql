SELECT *
FROM portfolioproject1.coviddeaths
where continent IS NOT NULL AND continent <> ''
order by 3,4;

/*SELECT *
FROM portfolioproject1.covidvaccinations
order by 3,4;*/

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject1.coviddeaths
where continent IS NOT NULL AND continent <> ''
order by 1,2;

-- looking at total cases/total deaths
-- shows likelihood of dying if you contract in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from portfolioproject1.coviddeaths
where continent IS NOT NULL AND continent <> ''
and location like '%states%'
order by 1,2;

-- looking at total cases vs population
-- show what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as infection_percentage
from portfolioproject1.coviddeaths
where continent IS NOT NULL AND continent <> ''
-- location like '%states%'
order by 1,2;

-- looking at countries with higest infection rate

select location, max(total_cases) as highest_infection_count, population, max((total_cases/population)*100) as infection_percentage
from portfolioproject1.coviddeaths
where continent IS NOT NULL AND continent <> ''
group by location, population 
order by infection_percentage desc;

-- showing countries with highest death count per population

Select Location, MAX(cast(total_deaths AS unsigned)) as TotalDeathCount
From PortfolioProject1.CovidDeaths
Where continent is not null AND continent <> ''
Group by Location
order by TotalDeathCount desc;

-- Let's break things by continent

Select continent, MAX(cast(total_deaths AS unsigned)) as TotalDeathCount
From PortfolioProject1.CovidDeaths
Where continent is not null AND continent <> ''
Group by continent
order by TotalDeathCount desc;

-- showing continents with highest death counts

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from portfolioproject1.coviddeaths
-- where location like '%states%'
where continent IS NOT NULL AND continent <> ''
group by date
order by 1,2;

-- Global numbers

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from portfolioproject1.coviddeaths
where continent IS NOT NULL AND continent <> ''
-- and location like '%states%'
order by 1,2;

select date, Sum(new_cases)
from portfolioproject1.coviddeaths
where continent IS NOT NULL AND continent <> ''
-- and location like '%states%'
group by date
order by 1,2;

select date, Sum(new_cases)as total_cases, sum(cast(new_deaths as unsigned))as total_deaths
from portfolioproject1.coviddeaths
where continent IS NOT NULL AND continent <> ''
-- and location like '%states%'
group by date
order by 1,2;

select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned))as total_deaths,
(sum(cast(new_deaths as unsigned))/new_cases)*100
as Death_percentage
from portfolioproject1.coviddeaths
where continent IS NOT NULL AND continent <> ''
-- and location like '%states%'
group by date
order by 1,2;

-- looking at total population vs vaccination

select * from portfolioproject1.coviddeaths dea
join portfolioproject1.covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date;

select dea.continent,dea.location, dea.date, dea.population
from portfolioproject1.coviddeaths dea
join portfolioproject1.covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.date is not null
order by 2,3;


-- using CTE

with PopvsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as unsigned)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from portfolioproject1.coviddeaths dea
join portfolioproject1.covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.date is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)
 from PopvsVac;
 
 -- temp table
 
-- Using Temp Table to perform Calculation on Partition By in previous query

-- DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
);
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast vac.new_vaccinations as unsigned) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3;
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;

 -- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 