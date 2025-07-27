SELECT * FROM portfolioproject.coviddeaths
order by 3;

SELECT * FROM portfolioproject.covidvaccinations
order by 3, 4;

-- Selecting columns that i'm going to work with
SELECT location, date, total_deaths, new_deaths, total_cases, new_cases, population 
FROM portfolioproject.coviddeaths;

-- Looking at Total Cases vs Total Death
-- Shows the Likelihood of death if you contact covid in your country
SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100, 2) as DeathPercent
FROM portfolioproject.coviddeaths;
 -- where location like '%afghan%';

-- Looking at Total Cases vs Population
-- shows what percentage of population got covid
SELECT location, date, Population, total_cases, round((total_cases/population) * 100, 2) as case_per_population
FROM portfolioproject.coviddeaths
order by case_per_population desc;
 -- where location like '%afghan%'

-- Looking for Countries with highest Infection Rate compare to Population

SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as 
case_per_population
FROM portfolioproject.coviddeaths
group by location, population
order by case_per_population desc;
 
 
 -- showing countries with highest death count per population
 
 SELECT location, max(total_deaths) as totalDeathCount
FROM portfolioproject.coviddeaths
-- where continent is not null
group by location
order by totalDeathCount desc;
 
 -- Lets Break it down by Continent 
 
SELECT location, max(total_deaths) as totalDeathCount
FROM portfolioproject.coviddeaths
where continent is null
group by location
order by totalDeathCount desc;

-- Showing the continent with the highest death count

SELECT continent, max(total_deaths) as totalDeathCount
FROM portfolioproject.coviddeaths
where continent is not null
group by continent
order by totalDeathCount desc;

-- Global Numbers

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
round(sum(new_deaths)/sum(new_cases) * 100,2) as DeathPercentage
 FROM portfolioproject.coviddeaths
where continent is not null;
-- group by date;
 -- where location like '%afghan%';

SELECT count(continent)
 FROM portfolioproject.coviddeaths;

-- Looking at Total Population vs Vaccination
-- Checking the percentage of people vaccinated in the world.


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by location order by dea.location, 
dea.date) as RollingPeopleVaccianted
FROM coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by 2,3;


-- USing CTE 

with PopvsVac (continent, location, date, popuation, new_vaccinations, 
RollingPeopleVaccianted) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by location order by dea.location, 
dea.date) as RollingPeopleVaccianted
FROM coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by 2,3
)select *, (RollingPeopleVaccianted/population)*100 
from PopvsVac;

-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated numeric,
) 

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by location order by dea.location, 
dea.date) as RollingPeopleVaccianted
FROM coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by 2,3;

select *, (RollingPeopleVaccianted/population)*100
from #PercentPopulationVaccinated;

-- Creating a view for later visualization

create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by location order by dea.location, 
dea.date) as RollingPeopleVaccianted
FROM coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by 2,3;

create view DeathPercentage as
SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
round(sum(new_deaths)/sum(new_cases) * 100,2) as DeathPercentage
 FROM portfolioproject.coviddeaths
where continent is not null;

create view case_per_population as 
SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as 
case_per_population
FROM portfolioproject.coviddeaths
group by location, population
order by case_per_population desc;





