function LL = CalculateLogLikehood(x,y,dxk,dx1,dyk,dy1,pxk,px1,pyk,py1,nbins)
        border = 2;
        LL = 0;
        for ii = y-border+1:y+border-1
            for jj = x-border+1:x+border-1
                vxk = dxk(ii,jj);
                bxk = uint8(vxk*nbins);
                if(bxk >= nbins) 
                    bxk = bxk - 1;
                end
                
                vx1 = dx1(ii,jj);
                bx1 = uint8(vx1*nbins);
                if(bx1 >= nbins)
                    bx1 = bx1 - 1;
                end
                
                vyk = dyk(ii,jj);
                byk = uint8(vyk*nbins);
                if(byk >= nbins) 
                    byk = byk - 1;
                end
                
                vy1 = dy1(ii,jj);
                by1 = uint8(vy1*nbins);
                if(by1 >= nbins)
                    by1 = by1 - 1;
                end
                
                pxk(bxk) = pxk(bxk)/(pxk(bxk) + px1(bx1));
                px1(bx1) = px1(bx1)/(pxk(bxk) + px1(bx1));
                
                pyk(byk) = pyk(byk)/(pyk(byk) + py1(by1));
                py1(by1) = py1(by1)/(pyk(byk) + py1(by1));
                
                
                LL = LL + (pxk(bxk)*log(pxk(bxk)/px1(bx1)) + pyk(byk)*log(pyk(byk)/py1(by1)));
            end
        end
