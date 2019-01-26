# Mental_Health_Issue_Tracker

Contributors:
- [Marcelle Chiriboga](https://github.com/mchiriboga)
- [Sayanti Ghosh](https://github.com/Sayanti86)

### Reflection on the usefulness of the feedback received

#### Feedback Process

During the feedback session, our app was reviewed by two teams, following three steps:

1. **Fly-on-the-wall**: We watched the reviewers interact with our app without any interference or direction from us.
2. **Informed-run**: The reviewers continued to explore the app, but this time with input from us.
3. **Written + Oral feedback**: We discussed the feedback with the reviewers and turned it into action items, captured on a GitHub issue.

This experience was very valuable, since it allowed us to notice how a user, who is not familiar with the app, would interact with it.

During the Fly-on-the-wall phase, we got great insight into which of our visualizations were more or less intuitive. We could
also observe whether users would run into the known issues we had, which helped us assess their impact.

As to the Informed-run, the main takeaway was identifying whether our analysis effectively communicated the ideas we
wanted, or if they could be misinterpreted.

Finally, the first two phases wouldn't be much use if we didn't get a chance to document their findings. So receiving the feedback
in the form of a GitHub issue was very helpful for us to ensure we'd have a chance to evaluate each one, prioritize, and make improvements accordingly.

#### Issues Found

Out of the insights and suggestions provided by the reviewing teams, the main items were:

- Add a descriptive title to the word cloud shown in the *Overview* tab
- Make the word cloud interactive
- Add a usage tab or introduction
- Review the tabs names to make them more descriptive
- Change the table output to a [DataTable](https://shiny.rstudio.com/articles/datatables.html)
- In the details tab, separate the plots slightly more or increase axis label text size
- Display the number of people surveyed with the filter options
- Change the default values for the age slider to be appropriate for tech companies

#### Priorization and Fixes

After receiving the feedback, we sat together and discussed each item in order to evaluate their priority
and difficulty to implement. In the end, we found them all to be relevant, but we knew we might not have enough time
to address all of them.

The first items we decided to address were the first two, related to the word cloud, a visualization that both teams found very interesting. Adding a title was straightforward, but the interactivity was one of our previously known issues, which we had already tried (and failed) to fix. Ultimately, we managed to add the desired level of interactivity by allowing the age and country filters to be applied. One issue remained where for countries where only one condition was reported, the word cloud is not shown. That is, it needs at least two different terms to plot the cloud.

We added the usage tab as suggested, to help guide a user through the visualizations and filters, and to explain the background of the data. We also renamed the *Details* tab to *Analysis*, but kept the other names since we judged they were intuitive.

Finally, we focused on improving the visualizations of the app. We followed the suggestion of converting the table in the
*Data* tab to a `DataTable`, which made it more readable, interactive, and searchable. We also improved all of our charts, customizing the fonts and font sizes for axis labels and titles, and also adding data labels to all plots.

In the end, the only two points we didn't address from the feedback we received were the last two – *display the number of people surveyed with the filter options*, and *change the default values for the age slider to be appropriate for tech companies*. While the first felt like it would be nice to have, it didn't feel as high priority as the others, so we left it as something that could be improved in a later version. As to the second, we felt that our choice (20 to 45) was appropriate, so we kept it.

We made two other changes which was not given as feedback , but we felt necessary . One , to remove the filters from *Usage* tab as it was not required . Second,removing one of the plot from our *Overview* tab which was showing "How much employees are open to talk to their employers regarding their mental health issue". The rationale behind removing the plot is , it is possible employees are awrae of benefits but not comfortable discussing about their mental health . It is a fair choice of an individual that they would like to discuss about personal issues or not . That does not imply they are scared of discussing or unaware. Also taking initiaives for making people talk about it within organisation might not give any advantage to employers as it might get interpreted as interference given the sensitivity of the subject . Hence , we removed the plot.

### Reflection on how the project changed since Milestone 2

Most of the changes we made to the project since Milestone 2 were either driven by the feedback we received, or by improvements we already wanted to make but didn't get around to completing by then. Specifically, the word cloud was the visualization that changed the most, since we couldn't make it interactive at our first few attempts. In the end, we figured out that the data that the word cloud uses had to be filtered prior to calculating the frequencies of each condition.

Other changes were already outlined in the previous section. They were mostly around trying to make the app more pleasant and intuitive to use.

One final issue that we'd like to address to improve the visualizations is that right now, if the app is viewed on a window that is smaller than ~900 pixels, the plots look too narrow and the labels are overlapping, as the text sizes don't adjust automatically with the window size.
