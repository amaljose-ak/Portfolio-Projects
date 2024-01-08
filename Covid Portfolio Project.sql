select * 
from dbo.['CovidDeaths']
where continent is not null
order by 3,4

select *
from dbo.['CovidVaccinations']



-- selecting the data for use
select location,date,total_cases,new_cases,total_deaths,population
from dbo.['CovidDeaths']
order by 1,2

--Total cases vs total deaths 
select location,date,total_cases,total_deaths,(CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS death_Percentage
from dbo.['CovidDeaths']
where location like '%india%'
order by 1,2

-- Total case vs Population
-- showing the percentage of covid in the population
select location,date,total_cases,(CONVERT(float, total_cases) / CONVERT(float, population)) * 100 AS  Covid_Population_Percentage
from dbo.['CovidDeaths']
where location like '%states%'
order by 1,2

-- Looking at the countries has highest rates of infections compared to  population
select location, MAX(total_cases) AS highest_total_case,
    MAX(CAST(total_cases AS float) / CAST(population AS float)) * 100 AS Infected_Population_Percentage
from dbo.['CovidDeaths']

--where location like '%states%'
group by location,population 
order by Infected_Population_Percentage desc


--showing the countries with highest Death count per population
select location,continent,
    MAX(CAST(total_deaths AS int)) as total_deathCount
from dbo.['CovidDeaths']
--where location like '%states%'
where continent is not null
group by location,population ,continent
order by total_deathCount desc



-- Continents and total deathcount 
select continent,
    MAX(CAST(total_deaths AS int)) as total_deathCount
from dbo.['CovidDeaths']
--where location like '%states%'
where continent is not null
group by continent
order by total_deathCount desc


--full total continents
select location,
    MAX(CAST(total_deaths AS int)) as total_deathCount
from dbo.['CovidDeaths']
--where location like '%states%'
where continent is  null
group by location
order by total_deathCount desc



--Global Numbers
select sum(new_cases) as total_cases ,sum (cast(new_deaths as int) )as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.['CovidDeaths']
--where location like '%india%'
where continent is not null
--group by date
order by 1,2



-- Looking at Total Population vs vaccinations

select death.continent,death.location, death.date ,death.population,vacc.new_vaccinations
, sum(CONVERT(bigint,vacc.new_vaccinations )) OVER 
(Partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from dbo.['CovidDeaths'] death
join dbo.['CovidVaccinations'] vacc
on death.location=vacc.location
and death.date=vacc.date
where death.continent is not null
order by 2,3




-- use cte
with PopvsVac (continent,Location,Date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select death.continent,death.location, death.date ,death.population,vacc.new_vaccinations
, sum(CONVERT(bigint,vacc.new_vaccinations )) OVER 
(Partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from dbo.['CovidDeaths'] death
join dbo.['CovidVaccinations'] vacc
on death.location=vacc.location
and death.date=vacc.date
where death.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100 as vaccinated_Percentage
from PopvsVac



-- Temp Table
CREATE TABLE #PercentPopulationVaccinated (
    Continent nvarchar(255),
    Location nvarchar(255),
    Population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT
    death.continent,
    death.location,
    death.population,
    vacc.new_vaccinations,
    SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM
    dbo.['CovidDeaths'] death
JOIN
    dbo.['CovidVaccinations'] vacc
ON
    death.location = vacc.location
    AND death.date = vacc.date
WHERE
    death.continent IS NOT NULL;

-- Select from the temporary table
SELECT
    *,
    (RollingPeopleVaccinated / population) * 100 as vaccinated_Percentage
FROM
    #PercentPopulationVaccinated;




	-- Creating view to store data for later visualizations
	create view percentPopulationVaccinated as 
	SELECT
    death.continent,
    death.location,
    death.population,
    vacc.new_vaccinations,
    SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM
    dbo.['CovidDeaths'] death
JOIN
    dbo.['CovidVaccinations'] vacc
ON
    death.location = vacc.location
    AND death.date = vacc.date
WHERE
    death.continent IS NOT NULL;

select *
from percentPopulationVaccinated