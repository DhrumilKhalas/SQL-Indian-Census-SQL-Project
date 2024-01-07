


CREATE TABLE data1 (
    District TEXT,
    States TEXT,
    Growth TEXT,
    Sex_Ratio INTEGER,
    Literacy NUMERIC
);


INSERT INTO
    data1 (district, states, growth, sex_ratio, literacy)
VALUES
    ('Thane', 'Maharashtra', '36.01%', '886', '84.53');


CREATE TABLE data2 (
    District VARCHAR(100),
    States VARCHAR(100),
    Area_km2 VARCHAR(100),
    Population VARCHAR(100)
);


INSERT INTO
    TABLE_NAME (District, States, Area_km2, Population)
VALUES
    ('Adilabad', 'Andhra Pradesh', '16,105', '27,41,239');


SELECT
    *
FROM
    data1;


SELECT
    *
FROM
    data2;


SELECT
    COUNT(*)
FROM
    data1;


SELECT
    COUNT(*)
FROM
    data2;


-------------------------------------------------- Questions --------------------------------------------------


-- (1) Provide the dataset for Jharkhand and Bihar states.

SELECT
    *
FROM
    data1
WHERE
    states IN ('Jharkhand', 'Bihar');


-- (2) What is the total population of India?

SELECT
    SUM(REPLACE(Population, ',', ''):: NUMERIC) AS "total population"
FROM
    data2;


-- (3) What is the average growth rate for the country?

SELECT
    AVG(replace(growth, '%', ''):: NUMERIC) AS avg_growth
FROM
    data1;


-- (4) What is the average growth rate for each state?

SELECT
    states,
    AVG(replace(growth, '%', ''):: NUMERIC) AS avg_state_growth
FROM
    data1
GROUP BY
    states;


-- (5) What is the average sex ratio?

SELECT
    AVG(sex_ratio)
FROM
    data1;


-- (6) What is the average sex ratio for each state?

SELECT
    states,
    AVG(sex_ratio)
FROM
    data1
GROUP BY
    states;


-- (7) What is the rounded average sex ratio for each state?

SELECT
    states,
    round(AVG(sex_ratio), 0)
FROM
    data1
GROUP BY
    states


-- (8) What is the rounded average sex ratio for each state, presented in descending order?

SELECT
    round(AVG(sex_ratio), 0) AS avg_state_sex_ratio,
    states
FROM
    data1
GROUP BY
    states
ORDER BY
    avg_state_sex_ratio desc


-- (9) What is the average literacy rate?

SELECT
    AVG(literacy)
FROM
    data1;


-- (10) What is the average literacy rate for each state, presented in descending order?

SELECT
    AVG(literacy) AS avg_literacy_state,
    states
FROM
    data1
GROUP BY
    states
ORDER BY
    avg_literacy_state desc


-- (11) What is the average literacy rate for each state with rates above 90%, presented in descending order?

SELECT
    states,
    AVG(literacy) AS avg_literacy_rate
FROM
    data1
GROUP BY
    states
HAVING
    AVG(literacy) > 90
ORDER BY
    avg_literacy_rate desc


-- (12) What are the top 3 states with the highest average growth rates?

SELECT
    round(AVG(replace(growth, '%', ''):: NUMERIC), 0) AS avg_growth_rate,
    states
FROM
    data1
GROUP BY
    states
ORDER BY
    avg_growth_rate desc
LIMIT
    3


-- (13) What are the bottom 3 states with the lowest average sex ratios?

SELECT
    round(AVG(sex_ratio), 0) AS avg_sex_ratio,
    states
FROM
    data1
GROUP BY
    states
ORDER BY
    avg_sex_ratio
LIMIT
    3


-- (14) Provide a table showing the top 3 and bottom 3 states based on average literacy rates.

(
    SELECT
        states,
        AVG(literacy) AS avg_literacy_of_state
    FROM
        data1
    GROUP BY
        states
    ORDER BY
        avg_literacy_of_state DESC
    LIMIT
        3
)
UNION
(
    SELECT
        states,
        AVG(literacy) AS avg_literacy_of_state
    FROM
        data1
    GROUP BY
        states
    ORDER BY
        avg_literacy_of_state
    LIMIT
        3
);


-- (15) Provide a table showing both the top 3 and bottom 3 states based on average literacy rates.

SELECT
    states,
    avg_literacy_of_state
FROM
    (
        (
            SELECT
                states,
                AVG(literacy) AS avg_literacy_of_state
            FROM
                data1
            GROUP BY
                states
            ORDER BY
                avg_literacy_of_state DESC
            LIMIT
                3
        )
        UNION
        (
            SELECT
                states,
                AVG(literacy) AS avg_literacy_of_state
            FROM
                data1
            GROUP BY
                states
            ORDER BY
                avg_literacy_of_state
            LIMIT
                3
        )
    ) AS subquery
ORDER BY
    avg_literacy_of_state DESC;


-- (16) Provide the dataset for states whose names start with the letter 'A'.

SELECT
    *
FROM
    data1
WHERE
    states LIKE 'A%';


-- (17) List the distinct states whose names start with the letter 'A'.

SELECT
    DISTINCT states
FROM
    data1
WHERE
    states LIKE 'A%';


-- (18) Provide the dataset for states whose names start with the letter 'a' (case-insensitive). 

SELECT
    *
FROM
    data1
WHERE
    LOWER(states) LIKE 'a%';


-- (19) List the distinct states whose names start with the letter 'A' or 'B'.

SELECT
    DISTINCT states
FROM
    data1
WHERE
    states LIKE 'A%'
    OR states LIKE 'B%'
ORDER BY
    states;


-- (20) List the distinct states whose names start with the letter 'A' and end with 'm'.

SELECT
    DISTINCT states
FROM
    data1
WHERE
    states LIKE 'A%'
    AND states LIKE '%m';


-- (21) For each district, provide the estimated male and female populations based on the given sex ratio and overall population.
-- females/males = sex_ratio ... (1)
-- females + males = population ... (2)
-- females = population - males ... (3)
-- (population - males) = (sex_ratio) * males
-- population = males * (sex_ratio + 1)
-- males = population / (sex_ratio + 1)
-- females = population - (population / (sex_ratio + 1))

SELECT
    district,
    states,
    round((population_new / (sex_ratio + 1)), 0) males_population_district_wise,
    round(population_new - (population_new / (sex_ratio + 1)), 0) females_population_district_wise
FROM
    (
        SELECT
            a.district,
            a.states,
            round(a.sex_ratio:: DECIMAL / 1000, 3) AS sex_ratio,
            b.population,
            replace(b.population, ',', ''):: NUMERIC AS population_new
        FROM
            data1 a
            INNER JOIN data2 b ON a.district = b.district
    ) c


-- (22) For each state, provide the aggregated male and female populations based on the given sex ratio and overall district-wise populations.

SELECT
    d.states,
    SUM(d.males_population_district_wise) males_population_state_wise,
    SUM(d.females_population_district_wise) females_population_state_wise
FROM
    (
        SELECT
            district,
            states,
            round((population_new / (sex_ratio + 1)), 0) males_population_district_wise,
            round(population_new - (population_new / (sex_ratio + 1)), 0) females_population_district_wise
        FROM
            (
                SELECT
                    a.district,
                    a.states,
                    round(a.sex_ratio:: DECIMAL / 1000, 3) AS sex_ratio,
                    b.population,
                    replace(b.population, ',', ''):: NUMERIC AS population_new
                FROM
                    data1 a
                    INNER JOIN data2 b ON a.district = b.district
            ) c
    ) d
GROUP BY
    d.states
ORDER BY
    d.states asc;


-- (23) For each district, provide the total number of literate and illiterate people based on the given literacy ratio and overall population.
-- total literate people = literacy_ratio * population
-- total illiterate people = (1 - literacy_ratio) * population

SELECT
    c.district,
    c.states,
    round(c.literacy_ratio * c.population_new, 0) literate_people,
    round((1 - c.literacy_ratio) * c.population_new, 0) illiterate_people
FROM
    (
        SELECT
            a.district,
            a.states,
            round(a.literacy / 100, 4) literacy_ratio,
            b.population,
            replace(b.population, ',', ''):: NUMERIC AS population_new
        FROM
            data1 a
            INNER JOIN data2 b ON a.district = b.district
    ) c


-- (24) For each state, provide the aggregated total number of literate and illiterate people based on the given literacy ratio and overall district-wise populations.

SELECT
    d.states,
    SUM(d.literate_people_district_wise) literate_people_state_wise,
    SUM(d.illiterate_people_district_wise) illiterate_people_state_wise
FROM
    (
        SELECT
            c.district,
            c.states,
            round(c.literacy_ratio * c.population_new, 0) literate_people_district_wise,
            round((1 - c.literacy_ratio) * c.population_new, 0) illiterate_people_district_wise
        FROM
            (
                SELECT
                    a.district,
                    a.states,
                    round(a.literacy / 100, 4) literacy_ratio,
                    b.population,
                    replace(b.population, ',', ''):: NUMERIC AS population_new
                FROM
                    data1 a
                    INNER JOIN data2 b ON a.district = b.district
            ) c
    ) d
GROUP BY
    d.states
ORDER BY
    d.states;


-- (25) For each district, provide the population in the previous census and the current census based on the growth rate.
-- previous_census + growth * previous_census = population
-- previous_census = population / (1 + growth)

SELECT
    d.district,
    d.states,
    round((d.population_new / (1 + d.growth_new)), 0) previous_census_population_district_wise,
    d.population_new current_census_population_district_wise
FROM
    (
        SELECT
            a.district,
            a.states,
            a.growth,
            round(((replace(a.growth, '%', ''):: NUMERIC) / 100), 5) AS growth_new,
            round(a.literacy / 100, 4) literacy_ratio,
            b.population,
            replace(b.population, ',', ''):: NUMERIC AS population_new
        FROM
            data1 a
            INNER JOIN data2 b ON a.district = b.district
    ) d


-- (26) For each state, provide the aggregated population in the previous census and the current census based on the growth rate.

SELECT
    e.states,
    SUM(e.previous_census_population_district_wise) previous_census_population_state_wise,
    SUM(e.current_census_population_district_wise) current_census_population_state_wise
FROM
    (
        SELECT
            d.district,
            d.states,
            round((d.population_new / (1 + d.growth_new)), 0) previous_census_population_district_wise,
            d.population_new current_census_population_district_wise
        FROM
            (
                SELECT
                    a.district,
                    a.states,
                    a.growth,
                    round(((replace(a.growth, '%', ''):: NUMERIC) / 100), 5) AS growth_new,
                    round(a.literacy / 100, 4) literacy_ratio,
                    b.population,
                    replace(b.population, ',', ''):: NUMERIC AS population_new
                FROM
                    data1 a
                    INNER JOIN data2 b ON a.district = b.district
            ) d
    ) e
GROUP BY
    e.states
ORDER BY
    e.states;


-- (27) Provide the aggregated total population in the previous census and the current census for all states.

SELECT
    SUM(f.previous_census_population_state_wise) total_previous_census_population_state_wise,
    SUM(f.current_census_population_state_wise) total_current_census_population_state_wise
FROM
    (
        SELECT
            e.states,
            SUM(e.previous_census_population_district_wise) previous_census_population_state_wise,
            SUM(e.current_census_population_district_wise) current_census_population_state_wise
        FROM
            (
                SELECT
                    d.district,
                    d.states,
                    round((d.population_new / (1 + d.growth_new)), 0) previous_census_population_district_wise,
                    d.population_new current_census_population_district_wise
                FROM
                    (
                        SELECT
                            a.district,
                            a.states,
                            a.growth,
                            round(((replace(a.growth, '%', ''):: NUMERIC) / 100), 5) AS growth_new,
                            round(a.literacy / 100, 4) literacy_ratio,
                            b.population,
                            replace(b.population, ',', ''):: NUMERIC AS population_new
                        FROM
                            data1 a
                            INNER JOIN data2 b ON a.district = b.district
                    ) d
            ) e
        GROUP BY
            e.states
        ORDER BY
            e.states
    ) f


-- (28) Calculate the ratio of total previous census population to area and total current census population to area for all states.

SELECT
    (
        i.area_km2 / i.total_previous_census_population_state_wise
    ) total_previous_census_population_state_wise_vs_area,
    (
        i.area_km2 / i.total_current_census_population_state_wise
    ) total_current_census_population_state_wise_vs_area
FROM
    (
        SELECT
            q.*,
            r.area_km2
        FROM
            (
                SELECT
                    '1' AS keyy,
                    g.*
                FROM
                    (
                        SELECT
                            SUM(f.previous_census_population_state_wise) total_previous_census_population_state_wise,
                            SUM(f.current_census_population_state_wise) total_current_census_population_state_wise
                        FROM
                            (
                                SELECT
                                    e.states,
                                    SUM(e.previous_census_population_district_wise) previous_census_population_state_wise,
                                    SUM(e.current_census_population_district_wise) current_census_population_state_wise
                                FROM
                                    (
                                        SELECT
                                            d.district,
                                            d.states,
                                            round((d.population_new / (1 + d.growth_new)), 0) previous_census_population_district_wise,
                                            d.population_new current_census_population_district_wise
                                        FROM
                                            (
                                                SELECT
                                                    a.district,
                                                    a.states,
                                                    a.growth,
                                                    round(((replace(a.growth, '%', ''):: NUMERIC) / 100), 5) AS growth_new,
                                                    round(a.literacy / 100, 4) literacy_ratio,
                                                    b.population,
                                                    replace(b.population, ',', ''):: NUMERIC AS population_new
                                                FROM
                                                    data1 a
                                                    INNER JOIN data2 b ON a.district = b.district
                                            ) d
                                    ) e
                                GROUP BY
                                    e.states
                                ORDER BY
                                    e.states
                            ) f
                    ) g
            ) q
            INNER JOIN (
                SELECT
                    '1' AS keyy,
                    z.*
                FROM
                    (
                        SELECT
                            SUM(replace(area_km2, ',', ''):: NUMERIC) area_km2
                        FROM
                            data2
                    ) z
            ) r ON q.keyy = r.keyy
    ) i


-- (29) Output the top 3 districts with the highest literacy rates from each state.

SELECT
    a.*
FROM
    (
        SELECT
            district,
            states,
            literacy,
            RANK() OVER(
                PARTITION BY states
                ORDER BY
                    literacy desc
            ) rnk
        FROM
            data1
    ) a
WHERE
    a.rnk IN (1, 2, 3)
ORDER BY
    a.states;


-- (30) Output the top 3 districts with the lowest literacy rates from each state.

SELECT
    a.*
FROM
    (
        SELECT
            district,
            states,
            literacy,
            RANK() OVER(
                PARTITION BY states
                ORDER BY
                    literacy
            ) rnk
        FROM
            data1
    ) a
WHERE
    a.rnk IN (1, 2, 3)
ORDER BY
    a.states;


