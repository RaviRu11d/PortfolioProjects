select * from Public.covid_deaths
order by 3, 4;

-- Selecting the data that is gonna be used

select location, date, total_cases, new_cases, total_deaths, population
from Public.covid_deaths
order by 1, 2;

-- Total Cases vs Total Deaths comparision (weekly)

select location, date, total_cases, total_deaths, (Cast(total_deaths as FLOAT))/(CAST(total_cases as FLOAT))*100 as DeathPercentage
from Public.covid_deaths
where total_cases NotNull and continent notnull
order by 1,2;

-- Total Cases vs Population comparision (weekly)

select location, date, total_cases, population, (Cast(total_cases as FLOAT))/(Cast(population as FLOAT))*100 as InfectedRate
from Public.covid_deaths
where total_cases NotNull and continent notnull
order by 1,2;

-- Countries with the Highest Infection Rate in comparison to Population

select location, MAX(total_cases) as Highest_Infection_Count, population, MAX((Cast(total_cases as FLOAT))/(CAST(population as FLOAT)))*100 as Population_Infected_Percentage
from Public.covid_deaths
Where continent notnull
group by location, population
order by population_infected_percentage desc;

-- Countries with the Highest Death Count

Select Location, MAX(total_deaths) as Total_Death_Count
from Public.covid_deaths
Where continent notnull
group by location
order by Total_Death_Count desc;

-- Continents with Highest Death Count

Select location, MAX(total_deaths) as Total_Death_Count
from Public.covid_deaths
Where continent is Null and location Not Like '%income%'
group by location
order by Total_Death_Count desc;

-- Global Cases/Death Percentage

Select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(CAST(new_deaths as FLOAT)) / SUM(CAST(new_cases as FLOAT))*100 as Global_Death_Percentage
from public.covid_deaths
where continent notnull
order by 1,2;

-- New Vaccinations Arrival

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations_till_date
from public.covid_deaths dea
join public.covid_vaccinations vac
	on dea.location = vac.location
where dea.continent notnull and new_vaccinations notnull
and dea.date = vac.date
order by 2,3;

-- Total_vaccination_till_date vs populationA

With population_vs_vaccination (continent, location, date, population, new_vaccinaitons, total_vaccinations_till_date)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations_till_date
	from public.covid_deaths dea
	join public.covid_vaccinations vac
		on dea.location = vac.location
	where dea.continent notnull and new_vaccinations notnull
	and dea.date = vac.date
	-- 	order by 2,3;
)
	
select *, (CAST(total_vaccinations_till_date as float)/CAST(population as FLOAT))*100 as Vaccination_rate_vs_population
from population_vs_vaccination

-- Creating View to store data for later visualization

Create view TotalDeathsPerCountry as
Select Location, MAX(total_deaths) as Total_Death_Count
from Public.covid_deaths
Where continent notnull
group by location
order by Total_Death_Count desc;
