function [] = SPIDER_FW(prefix)

    file = ['data/', prefix, '.mat'];
    data = load(file);
    M_hat = data.M_hat;
    [n1, n2] = size(M_hat);
    x = zeros(n1, n2);
    Omega = data.Omega;
    [k, ~] = size(Omega);
    
    [S, m, b, gamma, t, sigma, ~] = parameter_setting();
    
    running_time = 0;
    
    result = zeros(1 + S, 4);
    result(1,:) = [0, running_time, Object(x, M_hat, Omega, sigma), sum(svd(x))];
    
    for epoch = 1:S
        tic;
        x_last = x;
        v_last = gradient(x_last, M_hat, Omega, sigma, n1, n2);
        for iteration = 1:m
            batch = randi(k, b, 1);
            v = v_last + (gradient(x, M_hat, Omega(batch, :), sigma, n1, n2) ...
                - gradient(x_last, M_hat, Omega(batch, :), sigma, n1, n2)) / b;
            v_last = v;
            [U, ~, V] = svds(v, 1);
            d = - t * U * V';
            x_last = x;
            x = x + gamma * (d - x);
        end
        slot = toc;
        running_time = running_time + slot;
        result(1 + epoch, :) = [epoch * m, running_time, Object(x, M_hat, Omega, sigma), sum(svd(x))];
    end
    
    save_file = ['result/', prefix, '_SPIDER_FW.mat'];
    save(save_file, 'result', 'x');
end