select * from 
portfolio_project..coviddeaths 
where continent is not null
order by 3,4

--select * from 
--portfolio_project..covidvaccinations
--order by 3,4

-- select data that we are going to be using

select location, date,total_cases,new_cases,total_deaths,population
from 
portfolio_project..coviddeaths order by 1,2

--lookng at total cases vs total deaths
--shows likelyhood of dying if you contract covid in your country

select location, date,total_cases,total_deaths,(total_deaths/total_cases)* 100
as Deathpercentage
from portfolio_project..coviddeaths
where location like '%states%'
and continent is not null
order by 1,2 

--looking at the total cases vs population
--shows what percentage of population got covid

select location, date,total_cases,population,(total_cases/population)* 100 
as percentpopulationinfected
from portfolio_project..coviddeaths
--where location like '%states%'
order by 1,2 

--looking at countries with highest infection rate compared to population

select location, population,max(total_cases) as highestinfectioncount,max((total_cases/population))*
100 as percentpopulationinfected
from portfolio_project..coviddeaths
--where location like '%states%'
group by population,location
order by percentpopulationinfected desc

--showing countries with highest death count per  population

select location, max(cast(Total_deaths as int)) as Totaldeathcount
from portfolio_project..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by  Totaldeathcount desc

--let break things by continent
--showing continents with the highest death count per population

select continent, max(cast(Total_deaths as int)) as Totaldeathcount
from portfolio_project..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by  Totaldeathcount desc

--Global Numbers

select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum
(new_cases )* 100 as DeathPercentage
from portfolio_project..coviddeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2 

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolio_project..Coviddeaths dea
 join portfolio_project..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --USE CTE
 
 with popvsvac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
 as
 (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolio_project..Coviddeaths dea
 join portfolio_project..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select * , (Rollingpeoplevaccinated/population)*100
 from popvsvac

-- Temp Table
Drop table if exists #percentpopulationvaccinated
create Table #percentpopulationvaccinated
(continent nvarchar(225),
location nvarchar (225),
Date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolio_project..Coviddeaths dea
 join portfolio_project..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3
 select * , (Rollingpeoplevaccinated/population)*100
 from #percentpopulationvaccinated


 --create view to store data for later  visualizations
 
 create view  percentpopulationvaccinated as 
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolio_project..Coviddeaths dea
 join portfolio_project..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3

 select * from percentpopulationvaccinated