function visualise_x_hat_graph(x_hat,axes,x_labels)
    % Plot x_hat on a bar graph
    bar(x_hat,'Parent',axes);
    xticks(axes,[1:1:length(x_hat)]);
    if length(x_hat)> 7
        xtickangle(axes,45);
    end
    xticklabels(axes,x_labels);
    ylim(axes,[-5,5])
    ylabel(axes,'Standard deviation from the mean')
    
